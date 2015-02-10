LineCollection = require 'a-mo.LineCollection'
Transform      = require 'a-mo.Transform'
Math           = require 'a-mo.Math'
Line           = require 'a-mo.Line'
log            = require 'a-mo.Log'
bit            = require 'bit'

class MotionHandler
	@version: 0x010001
	@version_major: bit.rshift( @version, 16 )
	@version_minor: bit.band( bit.rshift( @version, 8 ), 0xFF )
	@version_patch: bit.band( @version, 0xFF )
	@version_string: ("%d.%d.%d")\format @version_major, @version_minor, @version_patch

	new: ( @lineCollection, mainData, rectClipData = { }, vectClipData = { } ) =>
		-- Create a local reference to the options table.
		@options = @lineCollection.options
		@lineTrackingData = mainData.dataObject
		@rectClipData = rectClipData.dataObject
		@vectClipData = vectClipData.dataObject

		@callbacks = { }

		-- Do NOT perform any normal callbacks if mainData is shake
		-- rotoshape. In theory it would be possible to do plain translation
		-- because the SRS data contains a center_x and center_y field for
		-- each frame.
		unless 'SRS' == mainData.type or @options.main.clipOnly
			if @options.main.xPosition or @options.main.yPosition

				if @options.main.absPos
					@callbacks["(\\pos)%(([%-%d%.]+,[%-%d%.]+)%)"] = absolutePosition
				else
					@callbacks["(\\pos)%(([%-%d%.]+,[%-%d%.]+)%)"] = position

			if @options.main.origin
				@callbacks["(\\org)%(([%-%d%.]+,[%-%d%.]+)%)"] = origin

			if @options.main.xScale then
				@callbacks["(\\fsc[xy])([%d%.]+)"] = scale
				if @options.main.border
					@callbacks["(\\[xy]?bord)([%d%.]+)"] = scale
				if @options.main.shadow
					@callbacks["(\\[xy]?shad)([%-%d%.]+)"] = scale
				if @options.main.blur
					@callbacks["(\\blur)([%d%.]+)"] = blur

			if @options.main.zRotation
				@callbacks["(\\frz?)([%-%d%.]+)"] = rotate

		-- Don't support SRS for rectangular clips.
		if @rectClipData and 'SRS' != rectClipData.type
			@callbacks['(\\i?clip)(%([%-%d%.]+,[%-%d%.]+,[%-%d%.]+,[%-%d%.]+%))'] = rectangularClip

		if @vectClipData
			if 'SRS' == vectClipData.type
				@callbacks['(\\i?clip)(%([^,]-%))'] = vectorClipSRS
			else
				@callbacks['(\\i?clip)(%([^,]-%))'] = vectorClip

		@resultingCollection = LineCollection @lineCollection.sub
		@resultingCollection.shouldInsertLines = true
		@resultingCollection.options = @options
		-- This has to be copied over for clip interpolation
		@resultingCollection.meta = @lineCollection.meta
		for line in *@lineCollection.lines
			if @options.main.linear and not (@options.main.origin and line.hasOrg) and not ((@rectClipData or @vectClipData) and line.hasClip)
				line.method = linear
			else
				line.method = nonlinear

	applyMotion: =>
		setProgress = aegisub.progress.set
		setProgress 0

		totalLines = #@lineCollection.lines
		-- The lines are collected in reverse order in LineCollection so
		-- that we don't need to do things in reverse here.
		insertNumber = @lineCollection.lines[totalLines].number
		for index = 1, totalLines
			with line = @lineCollection.lines[index]

				-- start frame of line relative to start frame of tracked data
				.relativeStart = .startFrame - @lineCollection.startFrame + 1
				-- end frame of line relative to start frame of tracked data
				.relativeEnd = .endFrame - @lineCollection.startFrame
				.number = insertNumber
				.method @, line

			setProgress index/totalLines

		return @resultingCollection

	linear = ( line ) =>
		with line
			startFrameTime = aegisub.ms_from_frame aegisub.frame_from_ms .start_time
			frameAfterStartTime = aegisub.ms_from_frame aegisub.frame_from_ms(.start_time) + 1
			frameBeforeEndTime = aegisub.ms_from_frame aegisub.frame_from_ms(.end_time) - 1
			endFrameTime = aegisub.ms_from_frame aegisub.frame_from_ms .end_time
			-- Calculates the time length (in ms) from the start of the first
			-- subtitle frame to the actual start of the line time.
			beginTime = math.floor 0.5*(startFrameTime + frameAfterStartTime) - .start_time
			-- Calculates the total length of the line plus the difference
			-- (which is negative) between the start of the last frame the
			-- line is on and the end time of the line.
			endTime = math.floor 0.5*(frameBeforeEndTime + endFrameTime) - .start_time

			for pattern, callback in pairs @callbacks
				log.checkCancellation!
				.text = .text\gsub pattern, ( tag, value ) ->
					values = { }
					for frame in *{ line.relativeStart, line.relativeEnd }
						@lineTrackingData\calculateCurrentState frame
						values[#values+1] = callback @, value, frame
					("%s%s\\t(%d,%d,%s%s)")\format tag, values[1], beginTime, endTime, tag, values[2]

			if @options.main.xPosition or @options.main.yPosition
				.text = .text\gsub "\\pos(%b())\\t%((%d+,%d+),\\pos(%b())%)", ( start, time, finish ) ->
					"\\move" .. start\sub( 1, -2 ) .. ',' .. finish\sub( 2, -2 ) .. ',' .. time .. ")"

			@resultingCollection\addLine Line( line, nil, { wasLinear: true } ), nil, true, true

	nonlinear = ( line ) =>
		for frame = line.relativeEnd, line.relativeStart, -1
			with line
				aegisub.progress.set (frame - .relativeStart)/(.relativeEnd - .relativeStart) * 100
				log.checkCancellation!

				newStartTime = aegisub.ms_from_frame( @lineCollection.startFrame + frame - 1 )
				newEndTime   = aegisub.ms_from_frame( @lineCollection.startFrame + frame )

				timeDelta = newStartTime - aegisub.ms_from_frame( @lineCollection.startFrame + .relativeStart - 1 )

				newText = .text\gsub "\\fade(%b())", ( fade ) ->
					a1, a2, a3, t1, t2, t3, t4 = fade\match("(%d+),(%d+),(%d+),(%d+),(%d+),(%d+),(%d+)")
					t1, t2, t3, t4 = tonumber( t1 ), tonumber( t2 ), tonumber( t3 ), tonumber( t4 )
					-- beautiful.
					t1 -= timeDelta
					t2 -= timeDelta
					t3 -= timeDelta
					t4 -= timeDelta
					("\\fade(%s,%s,%s,%d,%d,%d,%d)")\format a1, a2, a3, t1, t2, t3, t4

				-- In theory, this is more optimal if we loop over the frames on
				-- the outside loop and over the lines on the inside loop, as
				-- this only needs to be calculated once for each frame, whereas
				-- currently it is being calculated for each frame for each
				-- line. However, if the loop structure is changed, then
				-- inserting lines into the resultingCollection would need to be
				-- more clever to compensate for the fact that lines would no
				-- longer be added to it in order.
				@lineTrackingData\calculateCurrentState frame

				-- iterate through the necessary operations
				for pattern, callback in pairs @callbacks
					newText = newText\gsub pattern, ( tag, value ) ->
						tag .. callback @, value, frame

				@resultingCollection\addLine Line( line, @resultingCollection, { text: newText, start_time: newStartTime, end_time: newEndTime, transformShift: timeDelta } ),
											 nil, true, true

	position = ( pos, frame ) =>
		x, y = pos\match "([%-%d%.]+),([%-%d%.]+)"
		x, y = positionMath x, y, @lineTrackingData
		("(%g,%g)")\format Math.round( x, 2 ), Math.round( y, 2 )

	positionMath = ( x, y, data ) ->
		x = (tonumber( x ) - data.xStartPosition)*data.xRatio
		y = (tonumber( y ) - data.yStartPosition)*data.yRatio
		radius = math.sqrt( x^2 + y^2 )
		alpha  = Math.dAtan( y, x )
		x = data.xCurrentPosition + radius*Math.dCos( alpha - data.zRotationDiff )
		y = data.yCurrentPosition + radius*Math.dSin( alpha - data.zRotationDiff )
		return x, y

	absolutePosition = ( pos, frame ) =>
		("(%g,%g)")\format Math.round( @lineTrackingData.xPosition[frame], 2 ), Math.round( @lineTrackingData.yPosition[frame], 2 )

	-- Needs to be fixed.
	origin = ( origin, frame ) =>
		ox, oy = origin\match("([%-%d%.]+),([%-%d%.]+)")
		ox, oy = positionMath ox, oy, @lineTrackingData
		("(%g,%g)")\format Math.round( ox, 2 ), Math.round( oy, 2 )

	scale = ( scale, frame ) =>
		scale *= @lineTrackingData.xRatio
		tostring Math.round scale, 2

	blur = ( blur, frame ) =>
		ratio = @lineTrackingData.xRatio
		ratio = 1 - (1 - ratio)*@options.main.blurScale

		tostring Math.round blur*ratio, 2

	rotate = ( rotation, frame ) =>
		rotation += @lineTrackingData.zRotationDiff
		tostring Math.round rotation, 2

	rectangularClip = ( clip, frame ) =>
		@rectClipData\calculateCurrentState frame

		return clip\gsub "([%.%d%-]+),([%.%d%-]+)", ( x, y ) ->
			x, y = positionMath x, y, @rectClipData
			("%g,%g")\format Math.round( x, 2 ), Math.round( y, 2 )

	vectorClip = ( clip, frame ) =>
		-- This is redundant if vectClipData is the same as
		-- lineTrackingData.
		@vectClipData\calculateCurrentState frame

		return clip\gsub "([%.%d%-]+) ([%.%d%-]+)", ( x, y ) ->
			x, y = positionMath x, y, @vectClipData
			("%g %g")\format Math.round( x, 2 ), Math.round( y, 2 )

	vectorClipSRS = ( clip, frame ) =>
		return '(' .. @vectClipData.data[frame] .. ')'

