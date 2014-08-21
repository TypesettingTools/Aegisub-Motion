Line = require 'a-mo.Line'
log  = require 'a-mo.Log'

class LineCollection

	new: ( @sub, sel, validationCb ) =>
		@lines = { }
		if sel
			@collectLines sel, validationCb
			if aegisub.frame_from_ms 0
				@getFrameInfo!

	addLine: ( line ) =>
		table.insert @lines, line

	generateMetaAndStyles: =>
		@styles = { }
		@meta   = { }
		for i = 1, #@sub
			line = @sub[i]

			if line.class == "style"
				@styles[line.name] = line
			-- not going to bother porting all the special-case bullshit over
			-- from karaskel.
			elseif line.class == "info"
				@meta[line.key] = line.value

	collectLines: ( sel, validationCb = ( line ) -> return not line.comment ) =>
		unless @meta and @styles
			@generateMetaAndStyles!

		dialogueStart = 0
		for x = 1, #@sub
			if @sub[x].class == "dialogue"
				dialogueStart = x - 1 -- start line of dialogue subs
				break

		@startTime  = @sub[sel[1]].start_time
		@endTime    = @sub[sel[1]].end_time

		for i = #sel, 1, -1
			with line = Line @sub[sel[i]], @
				if validationCb line
					.number = sel[i]
					.humanizedNumber = .number - dialogueStart
					.styleRef = @styles[.style]

					if .start_time < @startTime
						@startTime = .start_time

					if .end_time > @endTime
						@endTime = .end_time

					table.insert @lines, line

	getFrameInfo: =>
		frame_from_ms = aegisub.frame_from_ms
		ms_from_frame = aegisub.ms_from_frame

		for line in *@lines
			line.startFrame = frame_from_ms line.start_time
			line.endFrame   = frame_from_ms line.end_time

		@startFrame  = frame_from_ms @startTime
		@endFrame    = frame_from_ms @endTime
		@totalFrames = @endFrame - @startFrame

	callMethodOnAllLines: ( methodName, ... ) =>
		for line in *@lines
			line[methodName] line, ...

	sortLines: =>
		sortF = ({
			Time:   (l, n) -> { key: l.start_time, num: n, data: l }
			Actor:  (l, n) -> { key: l.actor,      num: n, data: l }
			Effect: (l, n) -> { key: l.effect,     num: n, data: l }
			Style:  (l, n) -> { key: l.style,      num: n, data: l }
			Layer:  (l, n) -> { key: l.layer,      num: n, data: l }
		})[sor]

		table.sort lines, (a, b) -> a.key < b.key or (a.key == b.key and a.num < b.num)

		strt = sel[1] + origselcnt - 1
		newsel = [i for i = strt, strt + #lines - 1]

	combineIdenticalLines: =>
		lastLine = @lines[1]
		newLineTable = { }
		for i = 2, #@lines
			log.checkCancellation!

			if lastLine\combineWithLine @lines[i]
				@shouldInsertLines = true
				continue
			else
				table.insert newLineTable, lastLine
				lastLine = @lines[i]

		table.insert newLineTable, lastLine
		@lines = newLineTable

	runCallback: ( callback ) =>
		for line in *@lines
			callback @, line

	deleteLines: =>
		for line in *@lines
			line\delete!

	deleteWithShift: =>
		shift = #@lines
		for line in *@lines
			line\delete!
			line.number -= shift
			shift -= 1

	insertLines: =>
		for line in *@lines
			@sub.insert line.number + 1, line

	replaceLines: =>
		if @shouldInsertLines
			@insertLines!
		else
			for line in *@lines
				@sub[line.number] = line
