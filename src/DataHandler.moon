local log
version = '1.0.5'

haveDepCtrl, DependencyControl = pcall require, 'l0.DependencyControl'

if haveDepCtrl
	version = DependencyControl {
		name: 'DataHandler',
		:version,
		description: 'A class for parsing After Effects motion data.',
		author: 'torque',
		url: 'https://github.com/TypesettingTools/Aegisub-Motion'
		moduleName: 'a-mo.DataHandler'
		feed: 'https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json'
		{
			{ 'a-mo.Log', version: '1.0.0' }
		}
	}
	log = version\requireModules!
else
	log  = require 'a-mo.Log'

class DataHandler
	@version: version

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
			width  = @rawData[3]\match "Source Width[\t ]+([0-9]+)"
			height = @rawData[4]\match "Source Height[\t ]+([0-9]+)"
			unless width and height
				return false
			@xPosScale = @scriptResX/tonumber width
			@yPosScale = @scriptResY/tonumber height

			parse @
			if #@xPosition != @length or #@yPosition != @length or #@xScale != @length or #@yScale != @length or #@zRotation != @length or 0 == @length
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
			unless line\match("^[\t ]+")
				if line == "Position"
					section = 1
				elseif line == "Scale"
					section = 2
				elseif line == "Rotation"
					section = 3
				else
					section = 0
			else
				line\gsub "^[\t ]+([%d%.%-]+)[\t ]+([%d%.%-e%+]+)(.*)", ( value1, value2, remainder ) ->
					switch section
						when 1
							table.insert @xPosition, @xPosScale*tonumber value2
							table.insert @yPosition, @yPosScale*tonumber remainder\match "^[\t ]+([%d%.%-e%+]+)"
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

if haveDepCtrl
	return version\register DataHandler
else
	return DataHandler
