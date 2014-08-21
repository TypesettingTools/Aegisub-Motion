log = require 'a-mo.Log'

class DataHandler

	new: ( rawDataString ) =>
		-- (length-22)/4
		if rawDataString
			unless @parseRawDataString rawDataString
				@parseFile rawDataString

	parseRawDataString: ( rawDataString ) =>
		@tableize rawDataString
		unless @rawData[1]\match "Adobe After Effects 6.0 Keyframe Data"
			return false
		@width  = @rawData[3]\match "Source Width\t([0-9]+)"
		@height = @rawData[4]\match "Source Height\t([0-9]+)"
		-- Might really not want to have a windowError here because it is
		-- possible to get this before the main dialog pops up, which seems
		-- pretty bad.
		unless @width and @height
			log.windowError "Your tracking data is either missing the Width/Height fields,\nor they are not where I expected them."
		parse @
		return true

	parseFile: ( fileName ) =>
		if file = io.open fileName, 'r'
			return @parseRawDataString file\read '*a'

		return false

	tableize: ( rawDataString ) =>
		@rawData = { }
		rawDataString\gsub "([^\r\n]+)", ( line ) ->
			table.insert @rawData, line

	parse = =>
		-- Initialize these here so they don't get appended if
		-- parseRawDataString is called twice.
		@xPosition = { }
		@yPosition = { }
		@xScale    = { }
		@yScale    = @xScale
		@zRotation = { }
		length = 0
		section = 0
		for _index, line in ipairs @rawData
			unless line\match("^\t")
				if line == "Position" or line == "Scale" or line == "Rotation"
					section += 1
			else
				line\gsub "^\t([%d%.%-]+)\t([%d%.%-e%+]+)(.*)", ( value1, value2, remainder ) ->
					switch section
						when 1
							table.insert @xPosition, tonumber value2
							table.insert @yPosition, tonumber remainder\match "\t([%d%.%-e%+]+)"
							length += 1
						when 2
							-- Sort of future proof against having different scale
							-- values for different axes.
							table.insert @xScale, tonumber value2
							-- table.insert @yScale, tonumber value2
						when 3
							-- Sort of future proof having rotation around different
							-- axes.
							table.insert @zRotation, -tonumber value2

		@length = length

	-- Arguments: just your friendly neighborhood options table.
	stripFields: ( options ) =>
		defaults = { xPosition: @xStartPosition, yPosition: @yStartPosition, xScale: @xStartScale, zRotation: @zStartRotation }
		for field, defaultValue in pairs defaults
			unless options[field]
				for index, value in ipairs @[field]
					@[field][index] = defaultValue

	checkLength: ( lineCollection ) =>
		if lineCollection.totalFrames == @length
			true
		else
			false

	addReferenceFrame: ( frame ) =>
		@startFrame = frame
		@xStartPosition = @xPosition[frame]
		@yStartPosition = @yPosition[frame]
		@zStartRotation = @zRotation[frame]
		@xStartScale    = @xScale[frame]
		@yStartScale    = @yScale[frame]

	calculateCurrentState: ( frame ) =>
		@xRatio = @xScale[frame]/@xStartScale
		@yRatio = @yScale[frame]/@yStartScale
		@zRotationDiff = @zRotation[frame] - @zStartRotation
