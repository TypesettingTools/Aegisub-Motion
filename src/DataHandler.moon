class DataHandler

	new: ( rawDataString ) =>
		-- (length-22)/4
		@tableize rawDataString
		@parsedData = {
			xPosition: { }
			yPosition: { }
			xScale: { }
			yScale: { }
			zRotation: { }
			width: rawDataString\match "Source Width\t([0-9]+)"
			height: rawDataString\match "Source Height\t([0-9]+)"
		}

	tableize: ( rawDataString ) =>
		@rawData = { }
		rawDataString\gsub "([^\n]+)", ( line ) ->
			table.insert @rawData, line

	parse: =>
		with @parsedData
			section = 0
			for _index, line in ipairs @parsedData
				unless line\match("^\t")
					if line == "Position" || line == "Scale" || line == "Rotation"
						section += 1
				else
					line\gsub "^\t([%d\.\-]+)\t([%d\.\-]+)\t", ( value1, value2 ) ->
						switch secti
							when 1
								table.insert .xpos, value1
								table.insert .ypos, value2
							when 2
								table.insert .xscl, value1
								table.insert .yscl, value2
							when 3
								table.insert .zrot, -value1

			-- To do: add some sane error checking
			-- .flength = #.xpos
			-- for x in *{#.ypos, #.xscl, #.yscl, #.zrot}
			-- 	windowerr x == .flength, 'Error parsing data. "After Effects Transform Data [anchor point, position, scale and rotation]" expected.'
