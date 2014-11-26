log = require 'a-mo.Log'
bit = require 'bit'

class ShakeShapeHandler
	@version: 0x010000
	@version_major: bit.rshift( @version, 16 )
	@version_minor: bit.band( bit.rshift( @version, 8 ), 0xFF )
	@version_patch: bit.band( @version, 0xFF )
	@version_string: ("%d.%d.%d")\format @version_major, @version_minor, @version_patch

	new: ( input, @scriptHeight ) =>
		if input
			unless @parseRawDataString input
				@parseFile input

		if @rawData
			@createDrawings!

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
		shapes = rawDataString\match "num_shapes (%d+)"
		@rawData = { }
		rawDataString\gsub "([^\r\n]+)", ( line ) ->
			if line\match "vertex_data"
				table.insert @rawData, line

		@numShapes = tonumber shapes
		@length = #@rawData / @numShapes

	createDrawings: =>
		@data = { }
		for baseIndex = 1, @length
			results = { }

			for curveIndex = baseIndex, @numShapes*@length, @length
				line = @rawData[curveIndex]
				table.insert results, convertVertex line, @scriptHeight

			table.insert @data, table.concat results, ' '

	fields = { "vx", "vy", "lx", "ly", "rx", "ry" }
	updateCurve = ( curve, height, args ) ->
		for index = 1, 6
			field = fields[index]
			if index % 2 == 0
				curve[field] = height - args[index]
			else
				curve[field] = args[index]

	convertVertex = ( vertex, scriptHeight ) ->
		drawString = {'m '}
		prevCurve = { }
		currCurve = { }
		vertex = vertex\gsub "vertex_data ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+", ( ... ) ->
			updateCurve prevCurve, scriptHeight, { ... }
			table.insert drawString, "#{prevCurve.vx} #{prevCurve.vy} b "
			return ""

		firstCurve = { k, v for k, v in pairs prevCurve }

		vertex\gsub "([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) ([%-%.%d]+) [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+ [%-%.%d]+", ( ... ) ->
			updateCurve currCurve, scriptHeight, { ... }
			table.insert drawString, "#{prevCurve.rx} #{prevCurve.ry} #{currCurve.lx} #{currCurve.ly} #{currCurve.vx} #{currCurve.vy} "
			prevCurve, currCurve = currCurve, prevCurve

		table.insert drawString, "#{prevCurve.rx} #{prevCurve.ry} #{firstCurve.lx} #{firstCurve.ly} #{firstCurve.vx} #{firstCurve.vy}"
		return table.concat drawString

	-- A function stub because I am too lazy to do this sort of thing
	-- properly.
	calculateCurrentState: =>

	checkLength: ( totalFrames ) =>
		if totalFrames == @length
			true
		else
			false
