local util, json, log, tags, Transform
version = '##__LINE_VERSION__##'

haveDepCtrl, DependencyControl = pcall require, 'l0.DependencyControl'

if haveDepCtrl
	version = DependencyControl {
		name: 'Line',
		:version,
		description: 'A class for containing and manipulating a line.',
		author: 'torque',
		url: 'https://github.com/TypesettingTools/Aegisub-Motion'
		moduleName: 'a-mo.Line'
		feed: 'https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json'
		{
			{ 'aegisub.util' }
			{ 'json' }
			{ 'a-mo.Log',       version: '##__LOG_VERSION__##'       }
			{ 'a-mo.Tags',      version: '##__TAGS_VERSION__##'      }
			{ 'a-mo.Transform', version: '##__TRANSFORM_VERSION__##' }
		}
	}
	util, json, log, tags, Transform = version\requireModules!

else
	util      = require 'aegisub.util'
	json      = require 'json'

	log       = require 'a-mo.Log'
	tags      = require 'a-mo.Tags'
	Transform = require 'a-mo.Transform'

frameFromMs = aegisub.frame_from_ms
msFromFrame = aegisub.ms_from_frame

tablesEqual = ( left, right ) ->
	return true if left == right
	return false unless type(left) == "table" and type(right) == "table"

	for key, value in pairs left
		return false unless right[key] == value
	for key, value in pairs right
		return false unless left[key] == value
	return true

class Line
	@version: version

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
	tPlaceholder: ( count ) -> "\\\3#{count}\\\3"
	tTokenPattern: "(\\\3(%d+)\\\3)"

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

	new: ( line, @parentCollection, overrides ) =>
		for field in *@fieldsToDeepCopy
			if "table" == type line[field]
				-- safe to assume that all fields to be deep copied are expected
				-- to be tables, otherwise they wouldn't be being deep copied
				if "table" == type( overrides ) and "table" == type overrides[field]
						@[field] = util.deep_copy overrides[field]
				else
					@[field] = util.deep_copy line[field]
			else
				if overrides[field] != nil
					@[field] = overrides[field]
				else
					@[field] = line[field]

		if "table" == type overrides
			for field in *@fieldsToCopy
				if overrides[field] != nil
					@[field] = overrides[field]
				else
					@[field] = line[field]
		else
			for field in *@fieldsToCopy
				@[field] = line[field]

		@duration = @end_time - @start_time

	-- Gathers extra line metrics: the alignment and position.
	-- Returns false if there is not already a position tag in the line.
	extraMetrics: ( styleRef = @styleRef ) =>
		alignPattern = tags.allTags.align.pattern
		posPattern   = tags.allTags.pos.pattern
		moveTag      = tags.allTags.move
		@runCallbackOnOverrides ( tagBlock ) =>
			tagBlock\gsub alignPattern, ( value ) ->
				unless @align
					@align = tonumber value

			tagBlock\gsub posPattern, ( value ) ->
				unless @xPosition or @move
					x, y = value\match "([%.%d%-]+),([%.%d%-]+)"
					@xPosition, @yPosition = tonumber( x ), tonumber( y )

			tagBlock\gsub moveTag.pattern, ( value ) ->
				unless @xPosition or @move
					@move = moveTag\convert value

		unless @align
			@align = styleRef.align

		unless @xPosition or @move
			@xPosition, @yPosition = @getDefaultPosition!
			return false

		return true

	formatTime = ( time ) ->
		seconds = time/1000
		minutes = seconds/60
		hours   = minutes/60
		return ("%d:%02d:%05.2f")\format math.floor( hours ), math.floor( minutes%60 ), seconds%60

	__tostring: =>
		@createRaw!
		return @raw

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
		deduplicateRepeatedTags = ( tagBlock ) ->
			for tag in *tags.repeatTags
				-- Replace all instances except the last one.
				_, num = tagBlock\gsub tag.pattern, ""
				tagBlock = tagBlock\gsub tag.pattern, "", num - 1
			return tagBlock

		-- note: most tags can appear multiple times in a line and only the
		-- last instance in a given tag block is used. Some tags (\pos,
		-- \move, \org, \an) can only appear once and only the first
		-- instance in the entire line is used.
		dedupPattern = ( tag ) -> tag.deduplicatePattern or tag.pattern
		validDedupMatch = ( tag, value ) ->
			return not tag.deduplicateValid or tag.deduplicateValid value
		firstValidMatch = ( text, tag ) ->
			startIndex = 1
			while true
				matchStart, matchEnd, value = text\find dedupPattern(tag), startIndex
				return nil unless matchStart
				return matchStart if validDedupMatch tag, value
				startIndex = matchEnd + 1
		removeTag = ( tagBlock, tag ) ->
			tagBlock = tagBlock\gsub dedupPattern(tag), ( value ) ->
				return nil unless validDedupMatch tag, value
				return ""
			return tagBlock

		tagCollection = { }
		comesBefore = ( left, right ) ->
			return left.block < right.block if left.block != right.block
			return left.offset < right.offset

		@runCallbackOnOverrides ( tagBlock, major ) =>
			for tag in *tags.oneTimeTags
				tagBlock = tagBlock\gsub dedupPattern(tag), ( value ) ->
					return nil unless validDedupMatch tag, value
					unless tagCollection[tag.name]
						tagCollection[tag.name] = {
							block: major
							offset: firstValidMatch tagBlock, tag
						}
						return nil
					else
						position = tagCollection[tag.name]
						log.debug "#{tag.name} previously found in block #{position.block} at #{position.offset}"
						return ""
			return tagBlock

		-- These pairs share renderer state, and only the first valid tag is used.
		-- Rectangular clips are excluded because renderers apply them sequentially.
		for _, v in ipairs {
				{ "move", "pos" }
				{ "fade", "fad" }
				{ "vectClip", "vectiClip" }
			}
			if tagCollection[v[1]] and tagCollection[v[2]]
				if comesBefore tagCollection[v[1]], tagCollection[v[2]]
					-- get rid of tagCollection[v[2]]
					@runCallbackOnOverrides ( tagBlock ) =>
						return removeTag tagBlock, tags.allTags[v[2]]
				else
					-- get rid of tagCollection[v[1]]
					@runCallbackOnOverrides ( tagBlock ) =>
						return removeTag tagBlock, tags.allTags[v[1]]

		@runCallbackOnOverrides ( tagBlock ) =>
			transforms = { }
			tagBlock = tagBlock\gsub tags.allTags.transform.pattern, ( transform ) ->
				table.insert transforms, "\\t" .. transform
				return @.tPlaceholder #transforms
			tagBlock = deduplicateRepeatedTags tagBlock
			tagBlock = tagBlock\gsub @tTokenPattern, ( _, index ) ->
				return transforms[tonumber index]

			return tagBlock

		-- Tags inside each transform form a separate scope.
		@text = @text\gsub tags.allTags.transform.pattern, ( transform ) ->
			return "\\t" .. deduplicateRepeatedTags transform

		@text = @text\gsub @splitChar, "}{"
		@text = @text\gsub "{}", ""
		@text = @text\gsub "\\clip%(%)", ""  -- useless even inside transforms

	-- Find the first instance of an override tag in a line following
	-- startIndex.
	-- Arguments:
	-- tag [table]: A well-formatted tag table, probably taken from tags.allTags.
	-- text [string]: The text that will be searched for the tag.
	--   Default: @text, the entire line text.
	-- startIndex [number]: A number specifying the point at which the
	--   search should start.
	--   Default: 1, the beginning of the provided text block.

	-- Returns:
	-- - The value of the tag.
	-- On error:
	-- - nil
	-- - A string containing an error message.
	getTagValue: ( tag, text = @text, startIndex = 1 ) =>
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
			tagBlock = tagBlock\gsub tag.pattern, ->
				value = values[replacements]
				replacements += 1
				return tag\format value

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
			return callback @, tagBlock, major,
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
		unless styleRef
			lineNumber = @humanizedNumber or @number or "unknown"
			log.windowError "Line #{lineNumber} uses the nonexistent style \"#{@style}\"."

		@properties = { }
		for tag in *tags.styleTags
			switch tag.type
				when "alpha"
					@properties[tag] = tag\convert styleRef[tag.style]\sub( 3, 4 )

				when "color"
					@properties[tag] = tag\convert styleRef[tag.style]\sub( 5, 10 )

				else
					@properties[tag] = tag\convert styleRef[tag.style]

	-- Because duplicate tags may exist within transforms, it becomes
	-- useful to remove transforms from a line before doing various
	-- processing.
	tokenizeTransforms: =>
		unless @transformsAreTokenized
			@transforms = { }
			count = 0
			tagIndex = 0
			@runCallbackOnOverrides ( tagBlock ) =>
				tagIndex += 1
				return tagBlock\gsub tags.allTags.transform.pattern, ( transform ) ->
					count += 1
					token = @.tPlaceholder count
					transform = Transform\fromString transform, @duration, tagIndex, @
					transform.token = token
					@transforms[count] = transform
					-- create a token for the transforms
					return token

			@transformsAreTokenized = true

	loopOverTokenizedTransforms: ( callback ) =>
		if @transformsAreTokenized
			@runCallbackOnOverrides ( tagBlock ) =>
				return tagBlock\gsub @tTokenPattern, ( placeholder, index ) ->
					return callback @transforms[tonumber index], placeholder

	detokenizeTransformsCopy: ( shift = 0 ) =>
		if @transformsAreTokenized
			return @text\gsub "({.-})", ( tagBlock ) ->
				return tagBlock\gsub @tTokenPattern, ( placeholder, index ) ->
					transform = @transforms[tonumber index]
					transform.startTime -= shift
					transform.endTime   -= shift
					result = transform\toString!
					transform.startTime += shift
					transform.endTime   += shift
					return result

	detokenizeTransforms: ( shift = 0 ) =>
		@loopOverTokenizedTransforms ( transform, placeholder ) ->
			transform.startTime -= shift
			transform.endTime   -= shift
			result = transform\toString!
			transform.startTime += shift
			transform.endTime   += shift
			return result

		@transformsAreTokenized = false

	-- detokenize using transform.rawString
	dontTouchTransforms: =>
		@loopOverTokenizedTransforms ( transform, placeholder ) ->
			return "\\t" .. transform.rawString

		@transformsAreTokenized = false

	interpolateTransformsCopy: ( shift = 0, start = @start_time ) =>
		newText = @text
		@loopOverTokenizedTransforms ( transform, placeholder ) ->
			transform.startTime -= shift
			transform.endTime   -= shift
			frame = frameFromMs start
			newText = transform\interpolate @, newText, placeholder, math.floor( 0.5*( msFromFrame( frame ) + msFromFrame( frame + 1 ) ) ) - start
			transform.startTime += shift
			transform.endTime   += shift
			return nil

		return newText

	interpolateTransforms: ( shift = 0, start = @start_time ) =>
		newText = @text
		@loopOverTokenizedTransforms ( transform, placeholder ) ->
			transform.startTime -= shift
			transform.endTime   -= shift
			frame = frameFromMs start
			newText = transform\interpolate @, newText, placeholder, math.floor( 0.5*( msFromFrame( frame ) + msFromFrame( frame + 1 ) ) ) - start
			transform.startTime += shift
			transform.endTime   += shift
			return nil
		@text = newText

		@transformsAreTokenized = false

	shiftKaraoke: ( shift = @karaokeShift ) =>
		karaokeTag = tags.allTags.karaoke
		@runCallbackOnOverrides ( tagBlock ) =>
			return tagBlock\gsub karaokeTag.pattern, ( ... ) ->
				time = karaokeTag\convert ...

				if shift > 0
					oldShift = -shift
					newTime = time - shift
					shift -= time
					if newTime > 0
						if karaokeTag.tag == "\\kf"
							return karaokeTag\format( oldShift ) .. karaokeTag\format time
						else
							return karaokeTag\format newTime
					else
						return ""
				else
					return nil

	combineWithLine: ( line ) =>
		for field in *{
			'actor', 'class', 'comment', 'effect', 'layer', 'margin_l',
			'margin_r', 'margin_t', 'section', 'style', 'text'
		}
			return false unless @[field] == line[field]

		return false unless tablesEqual @extra, line.extra
		return false unless @start_time == line.end_time or @end_time == line.start_time

		@start_time = math.min @start_time, line.start_time
		@end_time = math.max @end_time, line.end_time
		return true

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
		if "table" != type @extra
			@extra = {}

		switch type data
			when "table"
				@extra[field] = json.encode data
			when "string"
				@extra[field] = data
			else
				@extra[field] = tostring data

	getExtraData: ( field ) =>
		if "table" != type @extra
			return nil

		value = @extra[field]
		success, res = pcall json.decode, value
		-- Should probably add something for luabins here but it is
		-- extremely stupid and dumb so I really don't want to.

		if success
			return res
		else
			return value

if haveDepCtrl
	return version\register Line
else
	return Line
