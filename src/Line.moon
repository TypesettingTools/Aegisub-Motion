log       = require 'a-mo.Log'
json      = require 'json'
tags      = require 'a-mo.Tags'
Transform = require 'a-mo.Transform'
util      = require 'aegisub.util'

class Line
	fieldsToDeepCopy: {
		'extra'
	}

	fieldsToCopy: {
		-- Line fields
		'actor', 'class', 'comment', 'effect', 'end_time',  'layer', 'margin_l', 'margin_r', 'margin_t', 'section', 'start_time', 'style', 'text'
		-- Our fields
		'number', 'transforms', 'transformShift', 'transformsAreTokenized', 'properties', 'styleRef', 'wasLinear'
	}

	splitChar:    "\\\6"
	tPlaceholder: "\\\3"

	defaultXPosition: {
		-- align 3, 6, 9
		( subResX, leftMargin, rightMargin ) ->
			return subResX - rightMargin
		-- align 1, 4, 7
		( subResX, leftMargin, rightMargin ) ->
			return leftMargin
		-- align 2, 5, 8
		( subResX, leftMargin, rightMargin ) ->
			return 0.5*subResX
	}

	defaultYPosition: {
		-- align 1, 2, 3
		( subResY, verticalMargin ) ->
			return subResY - verticalMargin
		-- align 4, 5, 6
		( subResY, verticalMargin ) ->
			return 0.5*subResY
		-- align 7, 8, 9
		( subResY, verticalMargin ) ->
			return verticalMargin
	}

	new: ( line, @parentCollection, overrides = { } ) =>
		for field in *@fieldsToDeepCopy
			if "table" == type line[field]
				@[field] = util.deep_copy overrides[field] or line[field]
			else
				@[field] = overrides[field] or line[field]

		for field in *@fieldsToCopy
			@[field] = overrides[field] or line[field]

		@duration = @end_time - @start_time

	-- Gathers extra line metrics: the alignment and position.
	-- Returns false if there is not already a position tag in the line.
	extraMetrics: ( styleRef = @styleRef ) =>
		alignPattern = tags.allTags.align.pattern
		posPattern   = tags.allTags.pos.pattern
		@runCallbackOnOverrides ( tagBlock ) =>
			tagBlock\gsub alignPattern, ( value ) ->
				unless @align
					@align = tonumber value

			tagBlock\gsub posPattern, ( value ) ->
				unless @xPosition
					x, y = value\match "([%.%d%-]+),([%.%d%-]+)"
					@xPosition, @yPosition = tonumber( x ), tonumber( y )

		unless @align
			@align = styleRef.align

		unless @xPosition
			@xPosition, @yPosition = @getDefaultPosition!
			return false

		return true

	-- this should not have been added and the name is probably misleading.
	moveToPosition: ( time ) =>
		moveTag = tags.allTags.move
		posTag = tags.allTags.pos
		found = false
		@runCallbackOnOverrides ( tagBlock ) =>
			tagBlock = tagBlock\gsub moveTag.pattern, ( value ) ->
				found = true
				move = moveTag\convert value
				progress = (time - move.start)/(move.end - move.start)
				newPos = moveTag\interpolate {move.x1, move.y1}, {move.x2, move.y2}, progress
				@xPosition = newPos[1]
				@yPosition = newPos[2]
				return posTag\format newPos

			return tagBlock
		-- shitty hacks
		return found

	formatTime = ( time ) ->
		seconds = time/1000
		minutes = seconds/60
		hours   = minutes/60
		return ("%d:%02d:%05.2f")\format hours, minutes%60, seconds%60

	createRaw: =>
		line = {
			(@comment and ("Comment: %d")\format( @layer ) or ("Dialogue: %d")\format( @layer ))
			formatTime @start_time
			formatTime @end_time
			@style
			@actor
			@margin_l
			@margin_r
			@margin_t
			@effect
			@text
		}

		@raw = table.concat line, ','

	generateTagIndex: ( major, minor ) ->
		return tonumber tostring( major ) .. "." .. tostring minor

	splitTagIndex: ( index ) ->
		major = math.floor index
		minor = tostring( index )\match "%d+.(%d+)"
		return major, tonumber minor

	-- Tries to guarantee there will be no redundantly duplicate tags in
	-- the line. Does no other processing. Unfortunately, actually doing
	-- this perfectly is very complicated because, for example, \t() is
	-- actually position dependent. e.g. with \t(\c&HFF0000&)\c&HFF0000&,
	-- the \t will not actually do anything.
	deduplicateTags: =>
		-- Combine contiguous override blocks.
		@text = @text\gsub "}{", @splitChar
		-- note: most tags can appear multiple times in a line and only the
		-- last instance in a given tag block is used. Some tags (\pos,
		-- \move, \org, \an) can only appear once and only the first
		-- instance in the entire line is used.
		tagCollection = { }
		positions = { }
		@runCallbackOnOverrides ( tagBlock, major ) =>
			for tagName in *tags.oneTimeTags
				tag = tags.allTags[tagName]
				tagBlock = tagBlock\gsub tag.pattern, ( value ) ->
					unless tagCollection[tagName]
						tagCollection[tagName] = @.generateTagIndex major, tagBlock\find tag.pattern
						return nil
					else
						log.debug "#{tagName} previously found at #{tagCollection[tagName]}"
						return ""
			return tagBlock

		-- Quirks: 2 clips are allowed, as long as one is vector and one is
		-- rectangular. Move and pos obviously conflict, and whichever is
		-- the first is the one that's used. The same happens with fad and
		-- fade. And again, the same with clip and iclip. Also, rectangular
		-- clips can exist inside of transforms. If a rect clip exists in a
		-- transform, its type (i or not) dictates the type of all rect
		-- clips in the line.
		for _, v in ipairs {
				{ "move", "pos" }
				{ "fade", "fad" }
				{ "rectClip", "rectiClip" }
				{ "vectClip", "vectiClip" }
			}
			if tagCollection[v[1]] and tagCollection[v[2]]
				if tagCollection[v[1]] < tagCollection[v[2]]
					-- get rid of tagCollection[v[2]]
					@runCallbackOnOverrides ( tagBlock ) =>
						tagBlock = tagBlock\gsub tags.allTags[v[2]].pattern, ""
				else
					-- get rid of tagCollection[v[1]]
					@runCallbackOnOverrides ( tagBlock ) =>
						tagBlock = tagBlock\gsub tags.allTags[v[1]].pattern, ""

		@runCallbackOnOverrides ( tagBlock ) =>
			for tagName in *tags.repeatTags
				tag = tags.allTags[tagName]
				-- Calculates the number of times the pattern will be replaced.
				_, num = tagBlock\gsub tag.pattern, ""
				-- Replaces all instances except the last one.
				tagBlock = tagBlock\gsub tag.pattern, "", num - 1

			return tagBlock

		-- Now the whole thing has to be rerun on the contents of all
		-- transforms.
		@text = @text\gsub @splitChar, "}{"
		@text = @text\gsub "{}", ""

	-- Find the first instance of an override tag in a line following
	-- startIndex.
	-- Arguments:
	-- tag [table]: A well-formatted tag table, probably taken from tags.allTags.
	-- startIndex [number]: A number specifying the point at which the
	--   search should start.
	--   Default: 1, the beginning of the provided text block.
	-- text [string]: The text that will be searched for the tag.
	--   Default: @text, the entire line text.

	-- Returns:
	-- - The value of the tag.
	-- On error:
	-- - nil
	-- - A string containing an error message.
	getTagValue: ( tag, text = @text ) =>
		unless tag
			return nil, "No tag table was supplied."

		value = text\match tag.pattern, startIndex
		if value
			return tag\convert value
		else
			return nil, "The specified tag could not be found"

	-- Find all instances of a tag in a line. Only looks through override
	-- tag blocks.
	getAllTagValues: ( tag ) =>
		values = { }
		@runCallbackOnOverrides ( tagBlock ) =>
			value = @getTagValue tag, tagBlock
			if value
				table.insert values, value
			return tagBlock

		return values

	-- Sets all values of a tag in a line. The provided table of values
	-- must have the same number of tables
	setAllTagValues: ( tag, values ) =>
		replacements = 1
		@runCallbackOnOverrides ( tagBlock ) =>
			tagBlock, count = tagBlock\gsub tag.pattern, ->
				tag.format\format values[replacements]
				replacements += 1

			return tagBlock

	-- combines getAllTagValues and setAllTagValues by running the
	-- provided callback on all of the values collected.
	modifyAllTagValues: ( tag, callback ) =>
		values = @getAllTagValues tag

		-- Callback modifies the values table in whatever way.
		callback @, values

		@setAllTagValues tag, values

	-- Adds an empty override tag to the beginning of the line text if
	-- there is not an override tag there already.
	ensureLeadingOverrideBlockExists: =>
		if '{' != @text\sub 1, 1
			@text = "{}" .. @text

	-- Runs the provided callback on all of the override tag blocks
	-- present in the line.
	runCallbackOnOverrides: ( callback, count ) =>
		major = 0
		@text = @text\gsub "({.-})", ( tagBlock ) ->
			major += 1
			return callback @, tagBlock, i,
			count

	-- Runs the provided callback on the first override tag block in the
	-- line, provided that override tag occurs before any other text in
	-- the line.
	runCallbackOnFirstOverride: ( callback ) =>
		@text = @text\gsub "^({.-})", ( tagBlock ) ->
			return callback @, tagBlock

	-- Runs the provided callback on all overrides that aren't the first
	-- one.
	runCallbackOnOtherOverrides: ( callback ) =>
		@text = @text\sub( 1, 1 ) .. @text\sub( 2, -1 )\gsub "({.-})", ( tagBlock ) ->
			return callback @, tagBlock

	getPropertiesFromStyle: ( styleRef = @styleRef ) =>
		@properties = { }
		for name, tag in pairs tags.allTags
			if tag.style
				switch tag.type
					when "alpha"
						@properties[name] = tag\convert styleRef[tag.style]\sub( 3, 4 )

					when "color"
						@properties[name] = tag\convert styleRef[tag.style]\sub( 5, 10 )

					else
						@properties[name] = tag\convert styleRef[tag.style]

	-- Because duplicate tags may exist within transforms, it becomes
	-- useful to remove transforms from a line before doing various
	-- processing.
	tokenizeTransforms: =>
		unless @transformsAreTokenized
			@transforms = { }
			count = 0
			@runCallbackOnOverrides ( tagBlock ) =>
				return tagBlock\gsub tags.allTags.transform.pattern, ( transform ) ->
					count += 1
					transform = Transform\fromString transform, @duration, @.generateTagIndex( tagBlock\find transform ), @
					@transforms[count] = transform
					-- create a token for the transforms
					return @tPlaceholder .. tostring( count ) .. @tPlaceholder
			@transformsAreTokenized = true

	loopOverTokenizedTransforms: ( callback ) =>
		if @transformsAreTokenized
			@runCallbackOnOverrides ( tagBlock ) =>
				return tagBlock\gsub @tPlaceholder .. "(%d+)" .. @tPlaceholder, callback

			@transformsAreTokenized = false

	detokenizeTransforms: =>
		@loopOverTokenizedTransforms ( index ) ->
			transform = @transforms[tonumber index]
			transform.startTime -= @transformShift
			transform.endTime -= @transformShift
			result = transform\toString!
			transform.startTime += @transformShift
			transform.endTime += @transformShift
			return result

		if @transformEnded
			@transformEnded = nil

	-- detokenize using transform.rawString
	dontTouchTransforms: =>
		@loopOverTokenizedTransforms ( index ) ->
			return "\\t" .. @transforms[tonumber index].rawString

	interpolateTransforms: =>
		@loopOverTokenizedTransforms ( index ) ->
			transform = @transforms[tonumber index]
			transform.startTime -= @transformShift
			transform.endTime -= @transformShift
			transform\gatherTagsInEffect!
			transform\collectPriorState @
			result = transform\interpolate aegisub.ms_from_frame(aegisub.frame_from_ms(@start_time)+1) - @start_time
			transform.startTime += @transformShift
			transform.endTime += @transformShift
			return result

	combineWithLine: ( line ) =>
		if @text == line.text and @style == line.style and (@start_time == line.end_time or @end_time == line.start_time)
			@start_time = math.min @start_time, line.start_time
			@end_time = math.max @end_time, line.end_time
			return true
		return false

	delete: ( sub = @parentCollection.sub ) =>
		unless sub
			log.windowError "Sub doesn't exist, so I can't delete things. This isn't gonna work."
		unless @hasBeenDeleted
			sub.delete @number
			@hasBeenDeleted = true

	getDefaultPosition: ( styleRef = @styleRef ) =>
		verticalMargin = if @margin_t == 0 then styleRef.margin_t else @margin_t
		leftMargin     = if @margin_l == 0 then styleRef.margin_l else @margin_l
		rightMargin    = if @margin_r == 0 then styleRef.margin_r else @margin_r
		align          = @align or styleRef.align
		return @defaultXPosition[align%3+1]( @parentCollection.meta.PlayResX, leftMargin, rightMargin ), @defaultYPosition[math.ceil align/3]( @parentCollection.meta.PlayResY, verticalMargin )

	setExtraData: ( field, data ) =>
		switch type data
			when "table"
				@extra[field] = json.encode data
			when "string"
				@extra[field] = data
			else
				@extra[field] = tostring data

	getExtraData: ( field ) =>
		value = @extra[field]
		success, res = pcall json.decode, value
		-- Should probably add something for luabins here but it is
		-- extremely stupid and dumb so I really don't want to.

		if success
			return res
		else
			return value
