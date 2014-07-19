Line = require "a-mo.Line"
log = require "a-mo.logging"

class LineCollection

	new: ( @sub, sel ) =>
		@lines = { }
		@collectLines sel

	generateMetaAndStyles: =>
		@styles = { }
		@meta   = { }
		for i = 1, #@sub
			line = @sub[i]

			if line.class == "style"
				@styles[l.name] = l
			-- not going to bother porting all the special-case bullshit over
			-- from karaskel.
			elseif line.class == "info"
				@meta[l.key] = l.value

	collectLines: ( sel ) =>
		dialogueStart = 0
		frame_from_ms = aegisub.frame_from_ms
		ms_from_frame = aegisub.ms_from_frame

		for x = 1, #@sub
			if @sub[x].class == "dialogue"
				dialogueStart = x - 1 -- start line of dialogue subs
				break

		@startTime  = @sub[sel[1]].start_time
		@endTime    = @sub[sel[1]].end_time
		@startFrame = frame_from_ms @startTime
		@endFrame   = frame_from_ms @endTime

		for i = #sel, 1, -1
			with line = Line @sub[sel[i]], @
				.number = sel[i]
				.humanizedNumber = .number - dialogueStart
				.styleref = @styles[.style]

				.startFrame = frame_from_ms .start_time
				.endFrame   = frame_from_ms .end_time

				if .startframe < @startFrame
					@startFrame = .startframe
					@startTime = ms_from_frame .startFrame

				if .endframe > @endFrame
					@endFrame = .endframe
					@startTime = ms_from_frame .endFrame

				if .endframe - .startframe > 1 and not .comment
					line.transformations = { }
					table.insert @lines, line

		@totalFrames = @endFrame - @startFrame + 1

	mungeLinesForFBF: =>
		for line in *@lines
			line\mungeForFBF!

	cleanLines: =>
		for line in *@lines
			line\cleanText!

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

	combineLines: =>
		changed = false
		for num in *sel
			check_user_cancelled!
			l1 = sub[num - 1]
			l2 = sub[num]
			if l1.text == l2.text and l1.effect == l2.effect
				l1.end_time = l2.end_time
				debug "Munched line %d", num
				sub[num - 1] = l1
				sub.delete num
				changed = true
		return changed
