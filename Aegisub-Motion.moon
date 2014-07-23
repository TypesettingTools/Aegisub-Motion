-- See LICENSE for more info about your rights as a person to be
-- rightfully persecuted

export script_name        = "Aegisub-Motion"
export script_description = "A set of tools for simplifying the process of creating and applying motion tracking data with Aegisub."
export script_author      = "torque"
export script_version     = "0xDEADBEEF"

local *
local interface, alltags

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
			-- autocopy:  { class: "label",    x: 0, y: 0,  width: 0,  height: 0, config: true, label: "", value: true }
			-- delsourc:  { class: "label",    x: 0, y: 0,  width: 0,  height: 0, config: true, label: "", value: false }
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

check_user_cancelled = ->
	error "User cancelled" if aegisub.progress.is_cancelled!

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
