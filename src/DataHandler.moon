log = require 'a-mo.Log'
bit = require 'bit'

class DataHandler
	@version: 0x010000
	@version_major: bit.rshift( @version, 16 )
	@version_minor: bit.band( bit.rshift( @version, 8 ), 0xFF )
	@version_patch: bit.band( @version, 0xFF )
	@version_string: ("%d.%d.%d")\format @version_major, @version_minor, @version_patch


	new: ( input, @scriptResX, @scriptResY ) =>
		-- (length-22)/4
		if input
			unless @parseRawDataString input
				@parseFile input

	parseRawDataString: ( rawDataString ) =>
		@tableize rawDataString
		if next @rawData
			unless @rawData[1]\match "Adobe After Effects 6.0 Keyframe Data"
				return false
			width  = @rawData[3]\match "Source Width\t([0-9]+)"
			height = @rawData[4]\match "Source Height\t([0-9]+)"
			unless width and height
				return false
			@xPosScale = @scriptResX/tonumber width
			@yPosScale = @scriptResY/tonumber height

			parse @
			if #@xPosition != @length or #@yPosition != @length or #@xScale != @length or #@yScale != @length or #@zRotation != @length
				return false

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
							table.insert @xPosition, @xPosScale*tonumber value2
							table.insert @yPosition, @yPosScale*tonumber remainder\match "\t([%d%.%-e%+]+)"
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

	checkLength: ( totalFrames ) =>
		if totalFrames == @length
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
		@xCurrentPosition = @xPosition[frame]
		@yCurrentPosition = @yPosition[frame]
		@xRatio = @xScale[frame]/@xStartScale
		@yRatio = @yScale[frame]/@yStartScale
		@zRotationDiff = @zRotation[frame] - @zStartRotation
