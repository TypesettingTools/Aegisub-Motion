karaskel = require "karaskel"
util = require "util"

class LineCollection

	new: ( sub, sel ) =>
		@lines = {}
		@collectLines sub, sel

	collectLines: ( sub, sel ) =>
		local dialogueStart
		for x = 1, #sub
			if sub[x].class == "dialogue"
				dialogueStart = x - 1 -- start line of dialogue subs
				break

		@meta, @styles = karaskel.collect_head sub, false
		@endFrame = aegisub.frame_from_ms sub[sel[1]].end_time
		@startFrame = aegisub.frame_from_ms sub[sel[1]].start_time

		preproc_line = karaskel.preproc_line
		frame_from_ms = aegisub.frame_from_ms
		ms_from_frame = aegisub.ms_from_frame

		for i = #sel, 1, -1
			with line = sub[sel[i]]
				.number = sel[i]
				.humanizedNumber = .number - dialogueStart

				preproc_line sub, @meta, @styles, line

				.startFrame = frame_from_ms .start_time
				.endFrame   = frame_from_ms .end_time

				if .startframe < @startframe
					@startframe = .startframe
					@startTime = ms_from_frame .startFrame

				if .endframe > @endframe
					@endframe = .endframe
					@startTime = ms_from_frame .endFrame

				if .endframe - .startframe > 1 and not .comment
					table.insert @lines, line

		@totalFrames = @endFrame - @startFrame + 1


	mungeLinesForFBF: =>
		shortFade = "\\fad%(([%d]+),([%d]+)%)"
		longFade  = "\\fade%(([%d]+),([%d]+),([%d]+),([%-%d]+),([%-%d]+),([%-%d]+),([%-%d]+)%)"
		alpha_from_style = util.alpha_from_style
		combineChar = string.char 6
		pow = math.pow

		for line in *@lines
			with line
				-- The first fad or fade that is found in the line is the one
				-- that is used.
				shortFadeStart, shortFadeEnd = .text\find shortFade
				longFadeStart, longFadeEnd   = .text\find longFade

				-- If both \fad and \fade are present, then get rid of all
				-- occurrences of whichever one does not come first
				if shortFadeStart && longFadeStart
					if shortFadeStart < longFadeStart
						.text = .text\gsub longFade, ""
						longFadeStart = nil
					else
						.text = .text\gsub shortFade, ""
						shortFadeStart = nil

				-- For both \fad and \fade, make sure that there are not repeat
				-- occurrences of the tag so that when they are turned into \t,
				-- and move them to the beginning of the line. This should
				-- theoretically ensure identical behavior between the before
				-- and after cases.
				if shortFadeStart
					.text = "{#{.text\sub shortFadeStart, shortFadeEnd}}#{.text\gsub shortFade, ""}"
				if longFadeStart
					.text = "{#{.text\sub longFadeStart, longFadeEnd}}#{.text\gsub longFade, ""}"

				-- Merge all contiguous comment/override blocks. This will make
				-- pretty much everything that follows a lot more sane.
				.text = .text\gsub "}{", combineChar

				-- To be updated.
				lextrans = (trans) ->
					t_start, t_end, t_exp, t_eff = trans\sub(2, -2)\match "([%-%d]+),([%-%d]+),([%d%.]*),?(.+)"
					t_exp = tonumber(t_exp) or 1
					table.insert .trans, {tonumber(t_start), tonumber(t_end), t_exp, t_eff}
					debug "Line %d: \\t(%g,%g,%g,%s) found", t_start, t_end, t_exp, t_eff

				alphafunc = ( alpha ) ->
					str = ""
					if tonumber(fstart) > 0
						str ..= ("\\alpha&HFF&\\t(%d,%s,1,\\alpha%s)")\format 0, fstart, alpha
					if tonumber(fend) > 0
						str ..= ("\\t(%d,%d,1,\\alpha&HFF&)")\format line.duration - tonumber(fend), line.duration
					str

				.text = .text\gsub "^{(.-)}", ( tagBlock ) ->
					if shortFadeStart
						replaced = false
						-- Not pedantically correct, as output will not be properly
						-- preserved with lines that set specific alpha values, such
						-- as \1a and so on. Additionally, doesn't handle the case
						-- of multiple alpha tags being placed in the same override
						-- block, and so can spawn more transforms than necessary.
						tagBlock = tagBlock\gsub "\\alpha(&H%x%x&)", ( alpha ) ->
							replaced = true
							alphafunc alpha
						unless replaced
							-- Has the same problem mentioned above.
							tagBlock ..= alphafunc alpha_from_style .styleref.color1
					else
						-- This is also completely wrong, as existing alpha tags
						-- aren't even taken into account. However, in this case,
						-- properly handling the fade is much more complex, as alpha
						-- tags influence both the starting and ending transparency
						-- of the fade in an additive fashion. Given that very few
						-- (if any) people use \fade, I don't think the effort
						-- necessary to fix this behavior is worth it at the moment.
						tagBlock = tagBlock\gsub "\\fade%(([%d]+),([%d]+),([%d]+),([%-%d]+),([%-%d]+),([%-%d]+),([%-%d]+)%)",
							(a, b, c, d, e, f, g) ->
								("\\alpha&H%02X&\\t(%s,%s,1,\\alpha&H%02X&)\\t(%s,%s,1,\\alpha&H%02X&)")\format(a, d, e, b, f, g, c)
					tagBlock\gsub "\\t(%b())", lextrans

					-- Purposefully leave the opening tag off so that the first
					-- block will not get picked up in the following block
					-- manipulations.
					tagBlock .. '}'

				.text = .text\gsub "({.-})", ( block ) ->
					if fstart
						block = block\gsub "\\alpha(&H%x%x&)", alphafunc
					block\gsub "\\t(%b())", lextrans
					block

				-- It is possible to have both a rectangular and vector clip in
				-- the same line. This is useful for masking lines with
				-- gradients. In order to be able to support this (even though
				-- motion tracking gradients is a bad idea and not endorsed by
				-- this author), we need to both support multiple clips in one
				-- line, as well as not convert rectangular-style clips to
				-- vector clips. To make our lives easier, we'll just not
				-- enforce any limits on the number of clips in a line and
				-- assume the user knows what they're doing.
				.text = .text\gsub "\\(i?clip)(%b())", ( clip, points ) ->
					.hasClip = true
					if points\match "[%-%d%.]+,[%-%d%.]+,[%-%d%.]+"
						.hasRectangularClip = true
					else
						points\gsub "%(([%d]*),?(.-)%)", ( scaleFactor, points ) ->
							.hasVectorClip = true
							if scaleFactor ~= ""
								scaleFactor = tonumber scaleFactor
								-- Other number separators such as ',' are valid in
								-- vector clips, but standard tools don't create them.
								-- Ignore that parser flexibility to make our lives less
								-- difficult. Convert everything to floating point
								-- values for simplicity's sake.
								points\gsub "([%.%d%-]+) ([%.%d%-]+)", ( x, y ) ->
									x = tonumber( x )/2^(scaleFactor - 1)
									y = tonumber( y )/2^(scaleFactor - 1)
									-- Round the calculated values so that they don't take
									-- up huge amounts of space.
									("%.2f %.2f")\format x, y
							points
					"\\#{clip}(#{points})"
				return line

