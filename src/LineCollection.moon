Line = require 'a-mo.Line'
log  = require 'a-mo.Log'
bit  = require 'bit'

frameFromMs = aegisub.frame_from_ms
msFromFrame = aegisub.ms_from_frame

class LineCollection
	@version: 0x010001
	@version_major: bit.rshift( @version, 16 )
	@version_minor: bit.band( bit.rshift( @version, 8 ), 0xFF )
	@version_patch: bit.band( @version, 0xFF )
	@version_string: ("%d.%d.%d")\format @version_major, @version_minor, @version_patch

	new: ( @sub, sel, validationCb, selectLines=true ) =>
		@lines = { }
		if sel and #sel>0
			@collectLines sel, validationCb, selectLines
			if frameFromMs 0
				@getFrameInfo!
		else
			for i=#@sub,1,-1 do
				if @sub[i].class == "dialogue" then
					@lastLineNumber = i
					@firstLineNumber = i
					break

	-- This method should update various properties such as
	-- (start|end)(Time|Frame).
	addLine: ( line, validationCb = (-> return true), selectLine=true, index=false ) =>
		if validationCb line
			line.parentCollection = @
			line.inserted = false
			line.selected = selectLine
			line.number = index==true and line.number or index or nil
			frame_from_ms = aegisub.frame_from_ms

			-- if @startTime is unset, @endTime should damn well be too.
			if @startTime
				if @startTime > line.start_time
					@startTime = line.start_time

				if @endTime < line.end_time
					@endTime = line.end_time

			else
				@startTime = line.start_time
				@endTime   = line.end_time

			if @hasMetaStyles
				line.styleRef = @styles[line.style]

			if @hasFrameInfo
				line.startFrame = frameFromMs line.start_time
				line.endFrame = frameFromMs line.end_time
				@startFrame  = frameFromMs @startTime
				@endFrame    = frameFromMs @endTime
				@totalFrames = @endFrame - @startFrame

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

			elseif line.class == "dialogue"
				break

		unless next @styles
			log.windowError "No styles could be found and I guarantee that's gonna break something."

		@hasMetaStyles = true

	collectLines: ( sel, validationCb = ( ( line ) -> return not line.comment), selectLines=true ) =>
		unless @hasMetaStyles
			@generateMetaAndStyles!

		dialogueStart = 0
		for x = 1, #@sub
			if @sub[x].class == "dialogue"
				dialogueStart = x - 1 -- start line of dialogue subs
				break

		@startTime  = @sub[sel[1]].start_time
		@endTime    = @sub[sel[1]].end_time
		@lastLineNumber = 0

		for i = #sel, 1, -1
			with line = Line @sub[sel[i]], @
				if validationCb line
					.number = sel[i]
					@firstLineNumber = math.min .number, @firstLineNumber or .number
					@lastLineNumber = math.max .number, @lastLineNumber
					.inserted = true
					.hasBeenDeleted = false
					.selected = selectLines
					.humanizedNumber = .number - dialogueStart
					.styleRef = @styles[.style]

					if .start_time < @startTime
						@startTime = .start_time

					if .end_time > @endTime
						@endTime = .end_time

					table.insert @lines, line

	getFrameInfo: =>

		for line in *@lines
			line.startFrame = frameFromMs line.start_time
			line.endFrame   = frameFromMs line.end_time

		@startFrame  = frameFromMs @startTime
		@endFrame    = frameFromMs @endTime
		@totalFrames = @endFrame - @startFrame
		@hasFrameInfo = true

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
		linesToSkip = { }
		for i = 2, #@lines
			log.checkCancellation!

			if lastLine\combineWithLine @lines[i]
				linesToSkip[#linesToSkip+1] = @lines[i]
				@shouldInsertLines = true
				continue
			else lastLine = @lines[i]
		@deleteLines linesToSkip


	runCallback: ( callback, reverse ) =>
		if reverse
			for index = #@lines, 1, -1
				callback @, @lines[index], #@lines - index + 1
		else
			for index = 1, #@lines
				callback @, @lines[index], index

	deleteLines: ( lines=@lines, doShift=true ) =>
		if lines.__class == Line
			lines = { lines }

		lineSet = {line,true for _,line in pairs lines when not line.hasBeenDeleted}
		-- make sure all lines are unique and have not actually been already removed
		lines = [k for k,v in pairs lineSet]

		@sub.delete [line.number for line in *lines when line.inserted]

		@lastLineNumber = @firstLineNumber
		shift = #lines or 0
		for line in *@lines
			if lineSet[line]
				line.hasBeenDeleted = true
				shift -= line.inserted and 1 or 0
			elseif not line.hasBeenDeleted and line.inserted
				line.number -= doShift and shift or 0
				@lastLineNumber = math.max(line.number, @lastLineNumber)

	insertLines: =>
		toInsert = [line for line in *@lines when not (line.inserted or line.hasBeenDeleted)]
		tailLines, numberedLines = {}, {}

		for i=1,#toInsert
			line = toInsert[i]
			if line.number
				numberedLines[#numberedLines+1] = line
				line.i = i
			else
				tailLines[#tailLines+1] = line
				line.number = @lastLineNumber + i
				line.inserted = true

		table.sort numberedLines, (a,b) ->
			return a.number < b.number or a.number==b.number and a.i < b.i
		for line in *numberedLines
			@sub.insert line.number, line
			line.inserted = true
			@lastLineNumber = math.max @lastLineNumber, line.number

		unless #tailLines==0
			@sub.insert @lastLineNumber+1, unpack tailLines
			@lastLineNumber = math.max @lastLineNumber, tailLines[#tailLines].number

	replaceLines: =>
		if @shouldInsertLines
			@insertLines!
		else
			for line in *@lines
				if line.inserted and not line.hasBeenDeleted
					@sub[line.number] = line
	getSelection: =>
		sel = [line.number for line in *@lines when line.selected and line.inserted and not line.hasBeenDeleted]
		return sel, sel[#sel]