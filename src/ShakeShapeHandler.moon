log = require 'a-mo.Log'

class ShakeShapeHandler

	new: ( input ) =>
		if input
			unless @parseRawDataString input
				@parseFile input

	parseRawDataString: ( rawDataString ) =>
		if rawDataString\match "^shake_shape_data 4.0"
			@tableize rawDataString
			return true

		return false

	parseFile: ( fileName ) =>
		if file = io.open fileName, 'r'
			return @parseRawDataString file\read '*a'

		return false

	tableize: ( rawDataString ) =>
		@rawData = { }
		rawDataString\gsub "([^\r\n]+)", ( line ) ->
			if line\match "vertex_data"
				table.insert @rawData, line

		@length = #@rawData

	createDrawings: ( scriptHeight ) =>
		@data = {}
		for line in *@rawData
			table.insert @data, convertVertex line, scriptHeight

	updateCurve = ( curve, height, ... ) ->
		args = { ... }
		for index = 1, 6
			field = ({ "vx", "vy", "lx", "ly", "rx", "ry" })[index]
			if index % 2 == 0
				curve[field] = height - args[index]
			else
				curve[field] = args[index]

	convertVertex = ( vertex, scriptHeight ) ->
		drawString = {'m '}
		prevCurve = { }
		currCurve = { }
		vertex = vertex\gsub "vertex_data ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+", ( vx, vy, lx, ly, rx, ry ) ->
			updateCurve prevCurve, scriptHeight, vx, vy, lx, ly, rx, ry
			table.insert drawString, "#{prevCurve.vx} #{prevCurve.vy} b "
			return ""

		firstCurve = { k, v for k, v in pairs prevCurve }

		vertex\gsub "([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+", ( vx, vy, lx, ly, rx, ry ) ->
			updateCurve currCurve, scriptHeight, vx, vy, lx, ly, rx, ry
			table.insert drawString, "#{prevCurve.rx} #{prevCurve.ry} #{currCurve.lx} #{currCurve.ly} #{currCurve.vx} #{currCurve.vy} "
			prevCurve, currCurve = currCurve, prevCurve

		table.insert drawString, "#{prevCurve.rx} #{prevCurve.ry} #{firstCurve.lx} #{firstCurve.ly} #{firstCurve.vx} #{firstCurve.vy}"
		return table.concat drawString
