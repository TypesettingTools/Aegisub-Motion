-- See COPYING for more info about your rights as a person to be
-- rightfully persecuted

export script_name        = "Aegisub-Motion"
export script_description = "A set of tools for simplifying the process of creating and applying motion tracking data with Aegisub."
export script_author      = "torque"
export script_version     = "0xDEADBEEF"

local *
local interface, alltags

require "karaskel"
require "clipboard"
success, re = pcall require, "aegisub.re"
re = require "re" unless success

onetime_init = ->
	-- Set up interface tables.
	interface = {
		main: {
			-- mnemonics: xyOCSBuRWen + G\A + Wl\A
			linespath: { class: "textbox",  x: 0, y: 1,  width: 10, height: 4,               name:  "linespath", hint: "Paste data or the path to a file containing it. No quotes or escapes." }
			preflabel: { class: "label",    x: 0, y: 13, width: 10, height: 1,                                   label: "                  Files will be written to this directory." }
			prefix:    { class: "label",    x: 0, y: 14, width: 10, height: 1 }
			datalabel: { class: "label",    x: 0, y: 0,  width: 10, height: 1,                                   label: "                       Paste data or enter a filepath." }
			optlabel:  { class: "label",    x: 0, y: 6,  width: 5,  height: 1,                                   label: "Data to be applied:" }
			rndlabel:  { class: "label",    x: 7, y: 6,  width: 3,  height: 1,                                   label: "Rounding" }
			xpos:      { class: "checkbox", x: 0, y: 7,  width: 1,  height: 1, config: true, name:  "xpos",      label: "&x",            value: true,   hint: "Apply x position data to the selected lines." }
			ypos:      { class: "checkbox", x: 1, y: 7,  width: 1,  height: 1, config: true, name:  "ypos",      label: "&y",            value: true,   hint: "Apply y position data to the selected lines." }
			origin:    { class: "checkbox", x: 2, y: 7,  width: 2,  height: 1, config: true, name:  "origin",    label: "&Origin",       value: false,  hint: "Move the origin along with the position." }
			clip:      { class: "checkbox", x: 4, y: 7,  width: 2,  height: 1, config: true, name:  "clip",      label: "&Clip",         value: false,  hint: "Move clip along with the position (note: will also be scaled and rotated if those options are selected)." }
			scale:     { class: "checkbox", x: 0, y: 8,  width: 2,  height: 1, config: true, name:  "scale",     label: "&Scale",        value: true,   hint: "Apply scaling data to the selected lines." }
			border:    { class: "checkbox", x: 2, y: 8,  width: 2,  height: 1, config: true, name:  "border",    label: "&Border",       value: true,   hint: "Scale border with the line (only if Scale is also selected)." }
			shadow:    { class: "checkbox", x: 4, y: 8,  width: 2,  height: 1, config: true, name:  "shadow",    label: "&Shadow",       value: true,   hint: "Scale shadow with the line (only if Scale is also selected)." }
			blur:      { class: "checkbox", x: 4, y: 9,  width: 2,  height: 1, config: true, name:  "blur",      label: "Bl&ur",         value: true,   hint: "Scale blur with the line (only if Scale is also selected, does not scale \\be)." }
			rotation:  { class: "checkbox", x: 0, y: 9,  width: 3,  height: 1, config: true, name:  "rotation",  label: "&Rotation",     value: false,  hint: "Apply rotation data to the selected lines." }
			posround:  { class: "intedit",  x: 7, y: 7,  width: 3,  height: 1, config: true, name:  "posround",  min: 0, max: 5,         value: 2,      hint: "How many decimal places of accuracy the resulting positions should have." }
			sclround:  { class: "intedit",  x: 7, y: 8,  width: 3,  height: 1, config: true, name:  "sclround",  min: 0, max: 5,         value: 2,      hint: "How many decimal places of accuracy the resulting scales should have (also applied to border, shadow, and blur)." }
			rotround:  { class: "intedit",  x: 7, y: 9,  width: 3,  height: 1, config: true, name:  "rotround",  min: 0, max: 5,         value: 2,      hint: "How many decimal places of accuracy the resulting rotations should have." }
			wconfig:   { class: "checkbox", x: 0, y: 11, width: 4,  height: 1,               name:  "wconfig",   label: "&Write config", value: false,  hint: "Write current settings to the configuration file." }
			relative:  { class: "checkbox", x: 4, y: 11, width: 3,  height: 1, config: true, name:  "relative",  label: "R&elative",     value: true,   hint: "Start frame should be relative to the line's start time rather than to the start time of all selected lines" }
			stframe:   { class: "intedit",  x: 7, y: 11, width: 3,  height: 1, config: true, name:  "stframe",                           value: 1,      hint: "Frame used as the starting point for the tracking data. \"-1\" corresponds to the last frame." }
			linear:    { class: "checkbox", x: 4, y: 12, width: 2,  height: 1, config: true, name:  "linear",    label: "Li&near",       value: false,  hint: "Use transforms and \\move to create a linear transition, instead of frame-by-frame." }
			sortd:     { class: "dropdown", x: 5, y: 5,  width: 4,  height: 1, config: true, name:  "sortd",     label: "Sort lines by", value: "Default", items: { "Default", "Time" }, hint: "The order to sort the lines after they have been tracked." }
			sortlabel: { class: "label",    x: 1, y: 5,  width: 4,  height: 1,               name:  "sortlabel", label: "      Sort Method:" }
			autocopy:  { class: "label",    x: 0, y: 0,  width: 0,  height: 0, config: true, label: "", value: true }
			delsourc:  { class: "label",    x: 0, y: 0,  width: 0,  height: 0, config: true, label: "", value: false }
		}
		clip: {
			-- mnemonics: xySRe + GCA
			clippath: { class: "textbox",   x: 0, y: 1,  width: 10, height: 4,               name:  "clippath", hint: "Paste data or the path to a file containing it. No quotes or escapes." }
			label:    { class: "label",     x: 0, y: 0,  width: 10, height: 1,              label: "                 Paste data or enter a filepath." }
			xpos:     { class: "checkbox",  x: 0, y: 6,  width: 1,  height: 1, config: true, name:  "xpos",     value: true,  label: "&x", hint: "Apply x position data to the selected lines." }
			ypos:     { class: "checkbox",  x: 1, y: 6,  width: 1,  height: 1, config: true, name:  "ypos",     value: true,  label: "&y", hint: "Apply y position data to the selected lines." }
			scale:    { class: "checkbox",  x: 0, y: 7,  width: 2,  height: 1, config: true, name:  "scale",    value: true,  label: "&Scale" }
			rotation: { class: "checkbox",  x: 0, y: 8,  width: 3,  height: 1, config: true, name:  "rotation", value: false, label: "&Rotation" }
			relative: { class: "checkbox",  x: 4, y: 6,  width: 3,  height: 1, config: true, name:  "relative", value: true,  label: "R&elative" }
			stframe:  { class: "intedit",   x: 7, y: 6,  width: 3,  height: 1, config: true, name:  "stframe",  value: 1 }
		}
		trim: {
			prefix:   { config: true, value: "?video/" }
			encoder:  { config: true, value: "x264" }
			encbin:   { config: true, value: "" }
			enccom:   { config: true, value: "" }
		}
		config: {
			cfgver:   { config: true, value: 1 }
		}
	}

	-- Set up encoder presets.
	encpre = {
		x264:    '"#{encbin}" --crf 16 --tune fastdecode -i 250 --fps 23.976 --sar 1:1 --index "#{prefix}#{index}.index" --seek #{startf} --frames #{lenf} -o "#{prefix}#{output}[#{startf}-#{endf}].mp4" "#{inpath}#{input}"'
		ffmpeg:  '"#{encbin}" -ss #{startt} -t #{lent} -sn -i "#{inpath}#{input}" "#{prefix}#{output}[#{startf}-#{endf}]-%%05d.jpg"'
		avs2yuv: 'echo FFVideoSource("#{inpath}#{input}",cachefile="#{prefix}#{index}.index").trim(#{startf},#{endf}).ConvertToRGB.ImageWriter("#{prefix}#{output}-[#{startf}-#{endf}]\\",type="png").ConvertToYV12 > "#{prefix}encode.avs"#{nl}mkdir "#{prefix}#{output}-[#{startf}-#{endf}]"#{nl}"#{encbin}" -o NUL "#{prefix}encode.avs"#{nl}del "#{prefix}encode.avs"'
		-- vapoursynth =
	}

init_input = (sub, sel) ->

	onetime_init!

	setundo = aegisub.set_undo_point
	printmem "GUI startup"

	conf, accd = dialogPreproc sub, sel

	-- cancel:Abort in the main dialog tells Esc key to abort the entire macro
	-- cancel:Cancel in \clip dialog tells Esc key to close it and go back to the main dialog
	btns = {
			main: makebuttons {{ok:"&Go"}, {clip:"&\\clip..."}, {cancel:"&Abort"}}
			clip: makebuttons {{ok:"&Go clippin'"}, {cancel:"&Cancel"}, {abort:"&Abort"}}
		}
	dlg = "main"

	config = {}
	while true
		local button

		with btns[dlg]
			button, config[dlg] = aegisub.dialog.display(gui[dlg], .__list, .__namedlist)

		switch button
			when btns.main.clip
				dlg = "clip"
				continue

			when btns.main.ok, btns.clip.ok
				config.clip = config.clip or {} -- solve indexing errors
				for field in *guiconf.clip
					if config.clip[field] == nil then config.clip[field] = interface.clip[field].value
				config.main.linespath = false if config.main.linespath == ""

				writeconf conf, {main: config.main, clip: config.clip, global: global} if config.main.wconfig

				config.main.stframe = 1 if config.main.stframe == 0 -- TODO: fix this horrible clusterfuck
				config.clip.stframe = 1 if config.clip.stframe == 0

				config.main.position = true if config.main.xpos or config.main.ypos
				config.clip.position = true if config.clip.xpos or config.clip.ypos

				config.main.yconst = not config.main.ypos
				config.main.xconst = not config.main.xpos
				config.clip.yconst = not config.clip.ypos
				config.clip.xconst = not config.clip.xpos -- TODO: remove unnecessary logic inversion

				config.clip.stframe = config.main.stframe if config.main.clip
				config.main.linear    = false if config.main.clip or config.clip.clippath

				if config.clip.clippath == "" or config.clip.clippath == nil
					if not config.main.linespath then windowerr false, "No tracking data was provided."
					config.clip.clippath = false
				else
					config.main.clip = false -- set clip to false if clippath exists

				aegisub.progress.title "Mincing Gerbils"
				printmem "Go"

				newsel = frame_by_frame sub, accd, config.main, config.clip
				if munch sub, newsel
					newsel = {}
					for x = 1, #sub
						table.insert newsel, x if tostring(sub[x].effect)\match("^aa%-mou")

				aegisub.progress.title "Reformatting Gerbils"
				cleanup sub, newsel, config.main, #accd.lines
				break

			else
				if dlg == 'main' or button == btns.clip.abort
					aegisub.progress.task "ABORT"
					aegisub.cancel!
				else
					dlg = "main"
					continue

	setundo "Motion Data"
	printmem "Closing"

populateInputBox = ->

	if global.autocopy
		paste = clipboard.get() or "" -- if there's nothing on the clipboard, clipboard.get retuns nil
		if global.acfilter
			if paste\match("^Adobe After Effects 6.0 Keyframe Data")
				interface.main.linespath.value = paste
		else
			interface.main.linespath.value = paste


frame_by_frame = (sub, accd, opts, clipopts) ->

	local *

	newlines = {} -- table to stick indices of tracked lines into for cleanup.
	operations = {} -- create a table and put the necessary functions into it, which will save a lot of if operations in the inner loop. This was the most elegant solution I came up with.
	mocha = {}
	clipa = {}
	dim = {x:accd.meta.res_x, y:accd.meta.res_y}
	_ = nil

	main = ->

		printmem "Start of main loop"

		calc_abs_frame = (opts) -> if opts.stframe >= 0 then opts.stframe else accd.totframes + opts.stframe + 1

		if opts.linespath
			parse_input mocha, opts.linespath, accd.meta.res_x, accd.meta.res_y
			assert accd.totframes == mocha.flength, ("Number of frames selected (%d) does not match parsed line tracking data length (%d).")\format accd.totframes, mocha.flength
			spoof_table mocha, opts
			mocha.start = calc_abs_frame opts if not opts.relative
			clipa = mocha if opts.clip

		if clipopts.clippath
			parse_input clipa, clipopts.clippath, accd.meta.res_x, accd.meta.res_y
			assert accd.totframes == clipa.flength, ("Number of frames selected (%d) does not match parsed clip tracking data length (%d).")\format accd.totframes, clipa.flength
			opts.linear = false -- no linear mode with moving \clip, sorry
			opts.clip = true -- simplify things a bit
			spoof_table clipa, clipopts
			spoof_table mocha, opts, #clipa.xpos if not opts.linespath
			clipa.start = calc_abs_frame clipopts if not clipopts.relative

		for v in *accd.lines -- comment lines that were commented in the thingy
			derp = sub[v.num]
			derp.comment = true
			sub[v.num] = derp
			v.comment = false if not v.is_comment

		if opts.position
			operations["(\\pos)%(([%-%d%.]+,[%-%d%.]+)%)"] = possify
			operations["(\\org)%(([%-%d%.]+,[%-%d%.]+)%)"] = orginate if opts.origin

		if opts.scale then
			operations["(\\fsc[xy])([%d%.]+)"] = scalify
			operations["(\\[xy]?bord)([%d%.]+)"] = scalify if opts.border
			operations["(\\[xy]?shad)([%-%d%.]+)"] = scalify if opts.shadow
			operations["(\\blur)([%d%.]+)"] = scalify if opts.blur

		operations["(\\frz?)([%-%d%.]+)"] = rotate if opts.rotation

		printmem "End of table insertion"

		modo = if opts.linear then linearmodo else nonlinearmodo
		for currline in *accd.lines
			with currline
				printmem "Outer loop"
				.rstartf = .startframe - accd.startframe + 1 -- start frame of line relative to start frame of tracked data
				.rendf = .endframe - accd.startframe -- end frame of line relative to start frame of tracked data
				clipa.clipme = true if opts.clip and .clip
				.effect = "aa-mou" .. .effect
				calc_rel_frame = (opts) ->
					if tonumber(opts.stframe) >= 0 then currline.rstartf + opts.stframe - 1 else currline.rendf + opts.stframe + 1
				mocha.start = calc_rel_frame opts if opts.relative
				clipa.start = calc_rel_frame clipopts if clipopts.relative and clipa.clipme

				ensuretags currline, opts, accd.styles, dim

				.alpha = -datan( .ypos - mocha.ypos[mocha.start], .xpos - mocha.xpos[mocha.start] )
				.beta  = -datan( .oypos - mocha.ypos[mocha.start], .oxpos - mocha.xpos[mocha.start] ) if opts.origin
				.orgtext = .text -- tables are passed as references.

				modo currline

		for x = #sub, 1, -1
			if tostring(sub[x].effect)\match "^aa%-mou"
				table.insert newlines, x -- seems to work as intended

		return newlines -- yeah mang

	float2str = (f) -> ("%g")\format round(f, opts.posround)

	linearmodo = (currline) ->
		with currline
			one = aegisub.ms_from_frame aegisub.frame_from_ms .start_time
			two = aegisub.ms_from_frame aegisub.frame_from_ms(currline.start_time) + 1
			three = aegisub.ms_from_frame aegisub.frame_from_ms(currline.end_time) - 1
			four = aegisub.ms_from_frame aegisub.frame_from_ms .end_time
			maths = math.floor(0.5*(one+two) - currline.start_time) -- this voodoo magic gets the time length (in ms) from the start of the first subtitle frame to the actual start of the line time.
			mathsanswer = math.floor(0.5*(three+four) - currline.start_time) -- and this voodoo magic is the total length of the line plus the difference (which is negative) between the start of the last frame the line is on and the end time of the line.

			posmatch, _ = "(\\pos)%(([%-%d%.]+,[%-%d%.]+)%)" -- CHK
			if operations[posmatch]
				.text = .text\gsub posmatch,
					(tag, val) ->
						exes, whys = {}, {}
						for x in *{.rstartf, .rendf}
							cx, cy = val\match("([%-%d%.]+),([%-%d%.]+)")
							mochaRatios mocha, x
							cx = (cx + mocha.diffx)*mocha.ratx + (1 - mocha.ratx)*mocha.currx
							cy = (cy + mocha.diffy)*mocha.raty + (1 - mocha.raty)*mocha.curry
							r = math.sqrt((cx - mocha.currx)^2+(cy - mocha.curry)^2)
							cx = mocha.currx + r*dcos(.alpha + mocha.zrotd)
							cy = mocha.curry - r*dsin(.alpha + mocha.zrotd)
							table.insert exes, float2str(cx)
							table.insert whys, float2str(cy)
						s = ("\\move(%s,%s,%s,%s,%d,%d)")\format exes[1], whys[1], exes[2], whys[2], maths, mathsanswer
						debug "%s", s
						s
				_, operations[posmatch] = operations[posmatch], nil

			for pattern, func in pairs operations -- iterate through the necessary operations
				check_user_cancelled!
				.text = .text\gsub pattern,
					(tag, val) ->
						values = {}
						for x in *{.rstartf, .rendf}
							mochaRatios mocha, x
							table.insert values, func(val, currline, mocha, opts, tag)
						("%s%g\\t(%d,%d,1,%s%g)")\format tag, values[1], maths, mathsanswer, tag, values[2]

			sub[.num] = currline
			operations[posmatch] = _

	nonlinearmodo = (currline) ->
		with currline
			_refresh = os.time!
			for x = .rendf, .rstartf, -1  -- new inner loop structure
				printmem "Inner loop"
				debug "Round %d", x
				if os.time! > _refresh + 1
					aegisub.progress.title ("Processing frame %g/%g")\format x, .rendf - .rstartf + 1
					_refresh = os.time!
				aegisub.progress.set (x - .rstartf)/(.rendf - .rstartf) * 100
				check_user_cancelled!

				.start_time = aegisub.ms_from_frame( accd.startframe + x - 1)
				.end_time   = aegisub.ms_from_frame( accd.startframe + x)

				if not .is_comment -- don't do any math for commented lines.
					.time_delta = .start_time - aegisub.ms_from_frame(accd.startframe)
					for kv in *.trans
						.text = transformate currline, kv
						check_user_cancelled!
					mochaRatios mocha, x

					for pattern, func in pairs operations -- iterate through the necessary operations
						.text = .text\gsub pattern, (tag, val) -> tag..func(val, currline, mocha, opts, tag)
						check_user_cancelled!

					if clipa.clipme
						.text = .text\gsub "\\i?clip%b()", (a) -> clippinate(currline, clipa, x), 1

					.text = .text\gsub '\1', ""

				sub.insert .num+1, currline
				.text = .orgtext

			sub.delete .num if global.delsourc

	main!

mochaRatios = (mocha, x) ->
	with mocha
		.ratx = .xscl[x] / .xscl[.start]
		.raty = .yscl[x] / .yscl[.start]
		.diffx = .xpos[x] - .xpos[.start]
		.diffy = .ypos[x] - .ypos[.start]
		.zrotd = .zrot[x] - .zrot[.start]
		.currx = .xpos[x]
		.curry = .ypos[x]

possify = (pos, line, mocha, opts) ->
	oxpos, oypos = pos\match "([%-%d%.]+),([%-%d%.]+)"
	nxpos, nypos = makexypos(tonumber(oxpos), tonumber(oypos), mocha)
	r = math.sqrt((nxpos - mocha.currx)^2 + (nypos - mocha.curry)^2)
	nxpos = mocha.currx + r*dcos(line.alpha + mocha.zrotd)
	nypos = mocha.curry - r*dsin(line.alpha + mocha.zrotd)
	debug "pos: (%f,%f) -> (%f,%f)", oxpos, oypos, nxpos, nypos
	return ("(%g,%g)")\format round(nxpos, opts.posround), round(nypos,opts.posround)

orginate = (opos, line, mocha, opts) ->
	oxpos,oypos = opos\match("([%-%d%.]+),([%-%d%.]+)")
	nxpos,nypos = makexypos(tonumber(oxpos), tonumber(oypos), mocha)
	debug "org: (%f,%f) -> (%f,%f)", oxpos, oypos, nxpos, nypos
	return ("(%g,%g)")\format round(nxpos, opts.posround), round(nypos, opts.posround)

makexypos = (xpos, ypos, mocha) ->
	nxpos = (xpos + mocha.diffx)*mocha.ratx + (1 - mocha.ratx)*mocha.currx
	nypos = (ypos + mocha.diffy)*mocha.raty + (1 - mocha.raty)*mocha.curry
	return nxpos, nypos

clippinate = (line, clipa, iter) ->
	local cx, cy, ratx, raty, diffrz
	with clipa
		cx, cy = .xpos[iter], .ypos[iter]
		ratx   = .xscl[iter]/.xscl[.start]
		raty   = .yscl[iter]/.yscl[.start]
		diffrz = .zrot[iter] - .zrot[.start]
	debug "cx: %f cy: %frx: %f ry: %f\nfrz: %f\n", cx, cy, ratx, raty, diffrz

	sclfac = 2^(line.sclip - 1)
	clip = line.clip\gsub "([%.%d%-]+) ([%.%d%-]+)", (x, y) ->
		xo, yo = x, y
		x = (tonumber(x) - clipa.xpos[clipa.start]*sclfac) * ratx
		y = (tonumber(y) - clipa.ypos[clipa.start]*sclfac) * raty
		r = math.sqrt(x^2+y^2)
		alpha = datan(y, x)
		x = cx*sclfac + r*dcos(alpha - diffrz)
		y = cy*sclfac + r*dsin(alpha - diffrz)
		debug "Clip: %d %d -> %d %d", xo, yo, x, y
		if line.rescaleclip
			x *= 1024/sclfac
			y *= 1024/sclfac
		("%d %d")\format round(x), round(y)

	scale = if line.rescaleclip then "11," else ""
	return ("\\%s(%s)")\format line.clips, scale..clip

transformate = (line, trans) ->
	t_s = trans[1] - line.time_delta
	t_e = trans[2] - line.time_delta
	debug "Transform: %d,%d -> %d,%d", trans[1], trans[2], t_s, t_e
	return line.text\gsub "\\t%b()", ("\\%st(%d,%d,%g,%s)")\format(string.char(1), t_s, t_e, trans[3], trans[4]), 1

scalify = (scale, line, mocha, opts, tag) ->
	newScale = scale*mocha.ratx -- sudden camelCase for no reason
	debug "%s: %f -> %f", tag\sub(2), scale, newScale
	return round(newScale, opts.sclround)

rotate = (rot, line, mocha, opts) ->
	zrot = rot + mocha.zrotd
	debug "frz: -> %f", zrot
	return round(zrot, opts.rotround)

confmaker = ->

	onetime_init!

	lvaltab = {}
	conf = configscope()
	if not readconf conf, {main: interface.conf, clip: interface.clip, global: global}
		warn "Config read failed!"

	if global.prefix\sub(#global.prefix) ~= pathSep
		global.prefix ..= pathSep

	for key, value in pairs global
		interface.conf[key].value = value if interface.conf[key]
	interface.conf.enccom.value = encpre[global.encoder] or interface.conf.enccom.value

	btns = {
			conf: makebuttons {{ok:"&Write"}, {local:"Write &local"}, {clip:"&\\clip..."}, {cancel:"&Abort"}}
			clip: makebuttons {{ok:"&Write"}, {local:"Write &local"}, {cancel:"&Cancel"}, {abort:"&Abort"}}
		}
	dlg = "conf"

	while true
		local clipconf, button, config

		with btns[dlg]
			button, config = aegisub.dialog.display(gui[dlg], .__list, .__namedlist)

		switch button
			when btns.conf.clip
				dlg = "clip"
				continue

			when btns.conf.ok, btns.conf.local, btns.clip.ok, btns.clip.local
				clipconf = clipconf or {}
				conf = aegisub.decode_path("?script/"..config_file) if button == "Write local"
				config.enccom = encpre[config.encoder] or config.enccom if global.encoder != config.encoder

				for key, value in pairs global
					global[key] = config[key]
					config[key] = nil

				for field in *guiconf.clip
					clipconf[field] = interface.clip[field].value if clipconf[field] == nil

				writeconf conf, {main: config, clip: clipconf, global: global}
				break

			else
				if dlg == "conf" or button == btns.clip.abort
					aegisub.cancel!
				else
					dlg = "conf"
					continue

-- Functions for more easily handling angles specified in degrees
dcos  = (a) -> math.cos math.rad a
dacos = (a) -> math.deg math.acos a
dsin  = (a) -> math.sin math.rad a
dasin = (a) -> math.deg math.asin a
dtan  = (a) -> math.tan math.rad a
datan = (y, x) -> math.deg math.atan2 y, x

check_user_cancelled = ->
	error "User cancelled" if aegisub.progress.is_cancelled!

makebuttons = (extendedlist) -> -- example: {{ok:'&Add'}, {load:'Loa&d...'}, {cancel:'&Cancel'}}
	btns = {__list:{}, __namedlist:{}}
	for L in *extendedlist
		for k,v in pairs L
			btns[k] = v
			btns.__namedlist[k] = v
			table.insert btns.__list, v
	btns

windowAssert = (bool, message) ->
	unless bool
		aegisub.dialog.display { { class:"label", label:message } }, { "&Close" }, { cancel:"&Close" }
		error message

printmem = (a) ->
	debug "%s memory usage: %gkB", tostring(a), collectgarbage "count"

round = (num, idp) ->
	mult = 10^(idp or 0)
	math.floor(num * mult + 0.5) / mult

isvideo = ->
	if aegisub.frame_from_ms 0
		return true
	else
		return false, "Validation failed: you don't have a video loaded."

aegisub.register_macro "Motion Data - Apply", "Applies properly formatted motion tracking data to selected subtitles.",
	init_input, isvideo

aegisub.register_macro "Motion Data - Trim", "Cuts and encodes the current scene for use with motion tracking software.",
	trimnthings, isvideo

if config_file
	aegisub.register_macro "Motion Data - Config", "Full config management.",
		confmaker
