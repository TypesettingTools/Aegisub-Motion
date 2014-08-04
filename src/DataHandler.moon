log = require 'a-mo.Log'

class DataHandler

	new: ( rawDataString ) =>
		-- (length-22)/4
		@xPosition = { }
		@yPosition = { }
		@xScale = { }
		@yScale = @xScale
		@zRotation = { }
		if rawDataString
			@parseRawDataString rawDataString

	parseRawDataString: ( rawDataString ) =>
		tableize @, rawDataString
		@width  = @rawData[3]\match "Source Width\t([0-9]+)"
		@height = @rawData[4]\match "Source Height\t([0-9]+)"
		unless @width and @height
			log.windowError "Your tracking data is either missing the Width/Height fields,\nor they are not where I expected them."
		parse @

	tableize = ( rawDataString ) =>
		@rawData = { }
		rawDataString\gsub "([^\r\n]+)", ( line ) ->
			table.insert @rawData, line

	parse = =>
		@length = 0
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
							@length += 1
						when 2
							-- Sort of future proof against having different scale
							-- values for different axes.
							table.insert @xScale, tonumber value2
							-- table.insert @yScale, tonumber value2
						when 3
							-- Sort of future proof having rotation around different
							-- axes.
							table.insert @zRotation, -tonumber value2

	-- Arguments: fieldsToRemove is a table of the following format:
	-- { "xPosition", "yPosition", "scale", "rotation" }
	-- where each value is a field to be removed from the tracking data.
	stripFields: ( fieldsToRemove ) =>
		defaults = { xPosition: 0, yPosition: 0, scale: 100, rotation: 0 }
		for _index, field in ipairs fieldsToRemove
			for index, value in ipairs @[field]
				@[field][index] = defaults[field]

	sanityCheck: ( lineCollection ) =>
		if lineCollection.totalFrames != @length
			log.windowError ("Number of frames selected (%d) does not match\nparsed line tracking data length (%d).")\format lineCollection.totalFrames, @length

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
