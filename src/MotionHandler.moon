LineCollection = require 'a-mo.LineCollection'
Line = require 'a-mo.Line'
Math = require 'a-mo.Math'
log = require 'a-mo.Log'

class MotionHandler

	new: ( @lineCollection, @lineTrackingData, @clipTrackingData ) =>
		-- create a local reference to the options table
		@options = @lineCollection.options

		@lineTrackingData\addReferenceFrame @options.main.startFrame

		if @clipTrackingData
			@clipTrackingData\addReferenceFrame @options.clip.startFrame
			@options.linear = false
			-- do in main: spoof lineTrackingData if it doesn't exist.
			-- Probably requires some modification to DataHandler

		elseif @options.main.clip
			@clipTrackingData = @lineTrackingData

		setCallbacks @

	setCallbacks = =>
		@callbacks = { }

		if @options.main.xPosition or @options.main.yPosition

			@callbacks["(\\pos)%(([%-%d%.]+,[%-%d%.]+)%)"] = position

			if @options.main.origin and not @options.main.linear
				@callbacks["(\\org)%(([%-%d%.]+,[%-%d%.]+)%)"] = origin

		if @options.main.scale then
			@callbacks["(\\fsc[xy])([%d%.]+)"] = scale
			if @options.main.border
				@callbacks["(\\[xy]?bord)([%d%.]+)"] = scale
			if @options.main.shadow
				@callbacks["(\\[xy]?shad)([%-%d%.]+)"] = scale
			if @options.main.blur
				@callbacks["(\\blur)([%d%.]+)"] = scale

		if @options.main.rotation
			@callbacks["(\\frz?)([%-%d%.]+)"] = rotate

		if @options.main.linear
			@resultingCollection = @lineCollection
			@work = linear
		else
			@resultingCollection = LineCollection @lineCollection.sub
			@resultingCollection.shouldInsertLines = true
			@work = nonlinear

	applyMotion: =>
		-- The lines are collected in reverse order in LineCollection so
		-- that we don't need to do things in reverse here.
		for line in *@lineCollection.lines
			with line
				if @options.clip and .hasClip
					@callbacks["(\\i?clip)(%b())"] = @clippinate

				-- start frame of line relative to start frame of tracked data
				.relativeStart = .startFrame - @lineCollection.startFrame + 1
				-- end frame of line relative to start frame of tracked data
				.relativeEnd = .endFrame - @lineCollection.startFrame

				.alpha = -Math.dAtan .yPosition - @lineTrackingData.yStartPosition, .xPosition - @lineTrackingData.xStartPosition

				if @options.origin
					.beta  = -Math.dAtan .yOrigin - @lineTrackingData.yStartPosition, .xOrigin - @lineTrackingData.xStartPosition

				@work line

		@resultingCollection

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

			for pattern, callback in pairs operations
				log.checkCancellation!
				.text = .text\gsub pattern, ( tag, value ) ->
					values = { }
					for frame in *{ line.relativeStart, line.relativeEnd }
						table.insert values, callback @, value
					("%s%s\\t(%d,%d,%s%s)")\format tag, values[1], beginTime, endTime, tag, values[2]

					callback @, tag, val, line

			if @options.main.position
				.text = .text\gsub "\\pos(%b())\\t%((%d,%d),\\pos(%b())%)", ( start, time, finish ) ->
					"\\move" .. start\sub( 1, -2 ) .. finish\sub( 2, -2 ) .. time .. ")"

	nonlinear = ( line ) =>
		for frame = line.relativeEnd, line.relativeStart, -1
			with line
				aegisub.progress.set (frame - .relativeStart)/(.relativeEnd - .relativeStart) * 100
				log.checkCancellation!

				newStartTime = aegisub.ms_from_frame( @lineCollection.startFrame + frame - 1 )
				newEndTime   = aegisub.ms_from_frame( @lineCollection.startFrame + frame )

				timeDelta = newStartTime - aegisub.ms_from_frame( @lineCollection.startFrame + .relativeStart )

				i = 0
				newText = .text\gsub "\\t%b()", ->
					i += 1
					start = .transformations[i][1] - timeDelta
					finish = .transformations[i][2] - timeDelta
					("\\t(%d,%d,%g,%s)")\format start, finish, .transformations[i][3], .transformations[i][4]

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
						tag .. callback @, value, frame, line

				@resultingCollection\addLine Line line, nil, { text: newText, start_time: newStartTime, end_time: newEndTime}

	position = ( pos, frame ) =>
		x, y = pos\match "([%-%d%.]+),([%-%d%.]+)"
		radius = math.sqrt (@lineTrackingData.xRatio*(x - @lineTrackingData.xStartPosition))^2 + (@lineTrackingData.yRatio*(y - @lineTrackingData.yStartPosition))^2
		x = @lineTrackingData.xPosition[frame] + radius*Math.dCos( line.alpha + @lineTrackingData.zRotationDiff )
		y = @lineTrackingData.yPosition[frame] - radius*Math.dSin( line.alpha + @lineTrackingData.zRotationDiff )
		("(%g,%g)")\format Math.round( x, @options.main.posround ), Math.round( y, @options.main.posround )

	absolutePosition = ( pos, frame ) =>
		("(%g,%g)")\format Math.round( @lineTrackingData.xPosition[frame], @options.main.posround ), Math.round( @lineTrackingData.xPosition[frame], @options.main.posround )

	-- Needs to be fixed.
	origin = ( origin, frame ) =>
		ox, oy = opos\match("([%-%d%.]+),([%-%d%.]+)")
		ox = @lineTrackingData.xRatio*(ox - @lineTrackingData.xStartPosition)
		oy = @lineTrackingData.yRatio*(oy - @lineTrackingData.yStartPosition)
		("(%g,%g)")\format Math.round( nxpos, @opts.main.posround ), Math.round( nypos, @opts.main.posround )

	scale = ( scale, frame ) =>
		scale *= @lineTrackingData.xRatio
		tostring Math.round scale, @options.main.sclround

	rotate = ( rotation, frame ) =>
		rotation += @lineTrackingData.zRotationDiff
		tostring Math.round rotation, @options.main.rotround

	vectorClip = ( clip, frame ) =>
		-- This is redundant if clipTrackingData is the same as
		-- lineTrackingData.
		@clipTrackingData\calculateCurrentState frame

		clip = clip\gsub "([%.%d%-]+) ([%.%d%-]+)", ( x, y ) ->
			x = (tonumber( x ) - @clipTrackingData.xStartPosition)*@lineTrackingData.xRatio
			y = (tonumber( y ) - @clipTrackingData.yStartPosition)*@lineTrackingData.yRatio
			radius = math.sqrt x^2 + y^2
			alpha = Math.dAtan y, x
			x += radius*Math.dCos( alpha - @lineTrackingData.zRotationDiff )
			y += radius*Math.dSin( alpha - @lineTrackingData.zRotationDiff )
			("%d %d")\format round( x, 2 ), round( y, 2 )

		("(%s)")\format clip
