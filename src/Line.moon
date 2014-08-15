log  = require 'a-mo.Log'
json = require 'json'


class Line
	fieldsToCopy: {
		-- Built in line fields
		"actor", "class", "comment", "effect", "end_time", "extra", "layer", "margin_l", "margin_r", "margin_t", "section", "start_time", "style", "text"
		-- Our fields
		"number"
	}

	repeatTags: {
		"fontName", "fontSize", "fontSp", "xscale", "yscale", "zrot", "xrot", "yrot", "border", "xborder", "yborder", "shadow", "xshadow", "yshadow", "reset", "alpha", "alpha1", "alpha2", "alpha3", "alpha4", "color1", "color2", "color3", "color4", "be", "blur", "xshear", "yshear", "drawing"
	}

	oneTimeTags: {
		"align", "pos", "move", "org", "fad", "fade", "rectClip", "rectiClip", "vectClip", "vectiClip"
	}

	allTags: {
		fontName: { pattern: "\\fn([^\\}]+)",      output: "string", type: "font",     format: "\\fn%s"              }
		fontSize: { pattern: "\\fs(%d+)",          output: "number", type: "scale",    format: "\\fs%d"              }
		fontSp:   { pattern: "\\fsp([%.%d%-]+)",   output: "number", type: "scale",    format: "\\fsp%g"             }
		xscale:   { pattern: "\\fscx([%d%.]+)",    output: "number", type: "scale",    format: "\\fscx%g"            }
		yscale:   { pattern: "\\fscy([%d%.]+)",    output: "number", type: "scale",    format: "\\fscx%g"            }
		zrot:     { pattern: "\\frz?([%-%d%.]+)",  output: "number", type: "rotation", format: "\\frz%g"             }
		xrot:     { pattern: "\\frx([%-%d%.]+)",   output: "number", type: "rotation", format: "\\frx%g"             }
		yrot:     { pattern: "\\fry([%-%d%.]+)",   output: "number", type: "rotation", format: "\\fry%g"             }
		border:   { pattern: "\\bord([%d%.]+)",    output: "number", type: "border",   format: "\\bord%g"            }
		xborder:  { pattern: "\\xbord([%d%.]+)",   output: "number", type: "border",   format: "\\xbord%g"           }
		yborder:  { pattern: "\\ybord([%d%.]+)",   output: "number", type: "border",   format: "\\ybord%g"           }
		shadow:   { pattern: "\\shad([%-%d%.]+)",  output: "number", type: "shadow",   format: "\\shad%g"            }
		xshadow:  { pattern: "\\xshad([%-%d%.]+)", output: "number", type: "shadow",   format: "\\xshad%g"           }
		yshadow:  { pattern: "\\yshad([%-%d%.]+)", output: "number", type: "shadow",   format: "\\yshad%g"           }
		reset:    { pattern: "\\r([^\\}]*)",       output: "string", type: "style",    format: "\\r%s"               }
		alpha:    { pattern: "\\alpha&H(%x%x)&",   output: "alpha",  type: "alpha",    format: "\\alpha&H%02X&"      }
		alpha1:   { pattern: "\\1a&H(%x%x)&",      output: "alpha",  type: "alpha",    format: "\\1a&H%02X&"         }
		alpha2:   { pattern: "\\2a&H(%x%x)&",      output: "alpha",  type: "alpha",    format: "\\2a&H%02X&"         }
		alpha3:   { pattern: "\\3a&H(%x%x)&",      output: "alpha",  type: "alpha",    format: "\\3a&H%02X&"         }
		alpha4:   { pattern: "\\4a&H(%x%x)&",      output: "alpha",  type: "alpha",    format: "\\4a&H%02X&"         }
		color1:   { pattern: "\\1?c&H(%x+)&",      output: "color",  type: "color",    format: "\\1c&H%02X%02X%02X&" }
		color2:   { pattern: "\\2c&H(%x+)&",       output: "color",  type: "color",    format: "\\2c&H%02X%02X%02X&" }
		color3:   { pattern: "\\3c&H(%x+)&",       output: "color",  type: "color",    format: "\\3c&H%02X%02X%02X&" }
		color4:   { pattern: "\\4c&H(%x+)&",       output: "color",  type: "color",    format: "\\4c&H%02X%02X%02X&" }
		be:       { pattern: "\\be([%d%.]+)",      output: "number", type: "blur",     format: "\\be%d"              }
		blur:     { pattern: "\\blur([%d%.]+)",    output: "number", type: "blur",     format: "\\blur%g"            }
		xshear:   { pattern: "\\fax([%-%d%.]+)",   output: "number", type: "shear",    format: "\\fax%g"             }
		yshear:   { pattern: "\\fay([%-%d%.]+)",   output: "number", type: "shear",    format: "\\fay%g"             }
		align:    { pattern: "\\an([1-9])",        output: "number", type: "align",    format: "\\an%d"              }
		drawing:  { pattern: "\\p(%d+)",           output: "number" }
		transform:{ pattern: "\\t(%b())",          output: "transform" }
		bold:     { pattern: "\\b(%d+)",           output: "number", type: "accent",   format: "\\b%d" }
		italic:   { pattern: "\\i([01])",          output: "number", type: "accent",   format: "\\i%d" }
		strike:   { pattern: "\\s([01])",          output: "number", type: "accent",   format: "\\s%d" }
		-- Problematic tags:
		pos:      { fieldnames: { "x", "y" },      output: "multi", pattern: "\\pos%(([%.%d%-]+,[%.%d%-]+)%)" }
		org:      { fieldnames: { "x", "y" },      output: "multi", pattern: "\\org%(([%.%d%-]+,[%.%d%-]+)%)" }
		fad:      { fieldnames: { "in", "out" },   output: "multi", pattern: "\\fad%((%d+,%d+)%)"             }
		vectClip: { fieldnames: { "scale", "shape" }, output: "multi", pattern: "\\clip%((%d+,)?([^,]-)%)" }
		vectiClip:{ fieldnames: { "scale", "shape" }, output: "multi", pattern: "\\iclip%((%d+,)?([^,]-)%)" }
		rectClip: { fieldnames: { "xLeft", "yTop", "xRight", "yBottom" }, output: "multi", pattern: "\\clip%(([%-%d%.]+,[%-%d%.]+,[%-%d%.]+,[%-%d%.]+)%)" }
		rectiClip:{ fieldnames: { "xLeft", "yTop", "xRight", "yBottom" }, output: "multi", pattern: "\\iclip%(([%-%d%.]+,[%-%d%.]+,[%-%d%.]+,[%-%d%.]+)%)" }
		move:     { fieldnames: { "x1", "y1", "x2", "y2", "start", "end" },     output: "multi", pattern: "\\move%(([%.%d%-]+,[%.%d%-]+,[%.%d%-]+,[%.%d%-]+,[%d%-]+,[%d%-]+)%)" }
		fade:     { fieldnames: { "a1", "a2", "a3", "a4", "in", "mid", "out" }, output: "multi", pattern: "\\fade%((%d+,%d+,%d+,%d+,[%d%-]+,[%d%-]+,[%d%-]+)%)" }

		-- add stuff like \\pos, \\move, \\org, \\fad, \\fade, and \\p
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
		for _, field in ipairs @fieldsToCopy
			@[field] = overrides[field] or line[field]
		@duration = @end_time - @start_time

	-- Gathers extra line metrics: the alignment and position.
	-- Returns false if there is not already a position tag in the line.
	extraMetrics: ( styleRef ) =>
		alignPattern = @allTags.align.pattern
		posPattern   = @allTags.pos.pattern
		@runCallbackOnOverrides ( tagBlock ) =>
			tagBlock\gsub alignPattern, ( value ) ->
				unless @align
					@align = tonumber value

			unless @align
				@align = styleRef.align

			tagBlock\gsub posPattern, ( value ) ->
				unless @xPosition
					x, y = value\match "([%.%d%-]+),([%.%d%-]+)"
					@xPosition, @yPosition = tonumber( x ), tonumber( y )

		unless @xPosition
			@xPosition, @yPosition = @getDefaultPosition styleRef
			return false

		return true

	-- Guarantees there will be no redundantly duplicate tags in the line.
	-- Does no other processing.
	deduplicateTags: =>
		-- Combine contiguous override blocks.
		@text = @text\gsub "}{", @splitChar
		-- note: most tags can appear multiple times in a line and only the
		-- last instance in a given tag block is used. Some tags (\pos,
		-- \move, \org, \an) can only appear once and only the first
		-- instance in the entire line is used.
		tags = { }
		positions = { }
		i = 0
		@runCallbackOnOverrides ( tagBlock ) =>
			for tagName in *@oneTimeTags
				tag = @allTags[tagName]
				tagBlock = tagBlock\gsub tag.pattern, ( value ) ->
					unless tags[tagName]
						log.debug "THIS TAG HAS NOT BEEN FOUND BEFORE: #{tagName}"
						tags[tagName] = tonumber "#{i}.#{tagBlock\find tag.pattern}"
						log.debug tags[tagName]
						return nil
					else
						log.debug "THIS TAG HAS BEEN FOUND BEFORE #{tagName}"
						return ""
				log.debug tagBlock
			i += 1
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
			if tags[v[1]] and tags[v[2]]
				if tags[v[1]] < tags[v[2]]
					-- get rid of tags[v[2]]
					@runCallbackOnOverrides ( tagBlock ) =>
						tagBlock = tagBlock\gsub @allTags[v[2]].pattern, ""
				else
					-- get rid of tags[v[1]]
					@runCallbackOnOverrides ( tagBlock ) =>
						tagBlock = tagBlock\gsub @allTags[v[1]].pattern, ""

		@runCallbackOnOverrides ( tagBlock ) =>
			for tagName in *@repeatTags
				tag = @allTags[tagName]
				-- Calculates the number of times the pattern will be replaced.
				_, num = tagBlock\gsub tag.pattern, ""
				-- Replaces all instances except the last one.
				tagBlock = tagBlock\gsub tag.pattern, "", num - 1

			return tagBlock

		-- Now the whole thing has to be rerun on the contents of all
		-- transforms.
		@text = @text\gsub @splitChar, "}{"
		@text = @text\gsub "{}", ""

	-- Converts a value matched from a tag.pattern into a meaningful
	-- format using tag.output.
	-- Inputs:
	-- tag [table]: Properly formatted tag table
	-- value [string]: value returned from tag.pattern.
	convertTagValue: ( tag, value ) =>
		switch tag.output
			when "string"
				return value

			when "number"
				return tonumber value

			when "alpha"
				return tonumber value, 16

			when "color"
				output = { }
				for i = 1, 5, 2
					table.insert output, tonumber value\sub( i, i+1 ), 16
				output.r = output[3]
				output.b = output[1]
				output.g = output[2]
				return output

			when "multi"
				output = { }
				value\gsub "[%.%d%-]+", ( coord ) ->
					table.insert output, coord

				i = 1
				for field in *tag.fieldnames
					output[field] = output[i]
					i += 1

				return output

			when "transform"
				return @parseTransform value

			else
				return nil, "Tag was somehow malformed."

	-- Find the first instance of an override tag in a line following
	-- startIndex.
	-- Arguments:
	-- tag [table]: A well-formatted tag table, probably taken from @allTags.
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
			return @convertTagValue tag, value
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
	runCallbackOnOverrides: ( callback ) =>
		log.debug @text
		@text = @text\gsub "({.-})", ( tagBlock ) ->
			return callback @, tagBlock
		log.debug @text

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

	-- Should not be a method of the line class, but I don't really have
	-- anywhere else to put it currently.
	parseTransform: ( transform ) =>
		transStart, transEnd, transExp, transEffect = transform\match "%(([%-%d]*),?([%-%d]*),?([%d%.]*),?(.+)%)"
		-- Catch the case of \t(2.345,\1c&H0000FF&), where the 2 gets
		-- matched to transStart and the .345 gets matched to transEnd.
		if tonumber( transStart ) and not tonumber( transEnd )
			transExp = transStart .. transExp
			transStart = ""

		transExp = tonumber( transExp ) or 1
		transStart = tonumber( transStart ) or 0

		transEnd = tonumber( transEnd ) or 0
		if transEnd == 0
			transEnd = @duration

		return {
			start:  transStart
			end:    transEnd
			accel:  transExp
			effect: transEffect
		}

	-- Because duplicate tags may exist within transforms, it becomes
	-- useful to remove transforms from a line before doing various
	-- processing.
	tokenizeTransforms: =>
		unless @transformsAreTokenized
			@transforms = { }
			count = 0
			@runCallbackOnOverrides ( tagBlock ) =>
				return tagBlock\gsub @allTags.transform.pattern, ( transform ) ->
					table.insert @transforms, @parseTransform transform

					count += 1
					-- create a token for the transforms
					return tPlaceholder .. tostring( count ) .. tPlaceholder
			@transformsAreTokenized = true

	detokenizeTransforms: =>
		if @transformsAreTokenized
			@runCallbackOnOverrides ( tagBlock ) =>
				tagBlock = tagBlock\gsub tPlaceholder .. "(%d+)" .. tPlaceholder, ( index ) ->
					-- this doesn't work because it's returning a table.
					return @transforms[index]

			@transformsAreTokenized = false

	combineWithLine: ( line ) =>
		if @text == line.text and @style == line.style and (@start_time == line.end_time or @end_time == line.start_time)
			@start_time = min @start_time, line.start_time
			@end_time = max @end_time, line.end_time
			return true
		return false

	delete: ( sub = @parentCollection.sub ) =>
		unless sub
			log.windowError "Sub doesn't exist, so I can't delete things. This isn't gonna work."
		unless @hasBeenDeleted
			sub.delete @number
			@hasBeenDeleted = true

	getDefaultPosition: ( styleRef ) =>
		verticalMargin = if @margin_t == 0 then styleRef.margin_t else @margin_t
		leftMargin     = if @margin_l == 0 then styleRef.margin_l else @margin_l
		rightMargin    = if @margin_r == 0 then styleRef.margin_r else @margin_r
		return @defaultXPosition( @parentCollection.meta.PlayResX, leftMargin, rightMargin ), @defaultYPosition( @parentCollection.meta.PlayResY, verticalMargin )

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

		if success
			return res
		else
			return value
