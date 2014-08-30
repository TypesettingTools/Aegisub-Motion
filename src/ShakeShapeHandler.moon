log = require 'a-mo.Log'

class ShakeShapeHandler
	new: ( rawDataString ) =>
		if rawDataString
			@parseRawDataString rawDataString

	parseRawDataString: ( rawDataString ) =>
		if rawDataString\match "shake_shape_data 4.0"
			@tableize rawDataString

	tableize: ( rawDataString ) =>
		@rawData = { }
		rawDataString\gsub "([^\r\n]+)", ( line ) ->
			if line\match "vertex_data"
				table.insert @rawData, line

		@length = #@rawData

	convertToDrawing: ( scriptHeight ) =>
		@data = {}
		for line in *@rawData
			@parseVertex line, scriptHeight

	updateCurve = ( curve, height, ... ) ->
		args = { ... }
		for index = 1, 6
			field = ({ "vx", "vy", "lx", "ly", "rx", "ry" })[index]
			if index % 2 == 0
				curve[field] = height - args[index]
			else
				curve[field] = args[index]

	parseVertex: ( line, scriptHeight ) =>
		drawString = {'m '}
		prevCurve = { }
		currCurve = { }
		line = line\gsub "vertex_data ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+", ( vx, vy, lx, ly, rx, ry ) ->
			updateCurve prevCurve, scriptHeight, vx, vy, lx, ly, rx, ry
			table.insert drawString, "#{prevCurve.vx} #{prevCurve.vy} b "
			return ""

		firstCurve = { k, v for k, v in pairs prevCurve }

		line\gsub "([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+", ( vx, vy, lx, ly, rx, ry ) ->
			updateCurve currCurve, scriptHeight, vx, vy, lx, ly, rx, ry
			table.insert drawString, "#{prevCurve.rx} #{prevCurve.ry} #{currCurve.lx} #{currCurve.ly} #{currCurve.vx} #{currCurve.vy} "
			prevCurve, currCurve = currCurve, prevCurve

		table.insert drawString, "#{prevCurve.rx} #{prevCurve.ry} #{firstCurve.lx} #{firstCurve.ly} #{firstCurve.vx} #{firstCurve.vy}"
		table.insert @data, table.concat drawString
