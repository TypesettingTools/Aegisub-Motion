ConfigHandler = require 'a-mo.ConfigHandler'
log = require 'a-mo.Log'

project_name = "Aegisub-Motion"
export script_name = "Tests/ConfigHandler"
export script_description = "Tests ConfigHandler class."

testConfigHandler = ( subtitles, selectedLines, activeLine ) ->
	interface = {
		main: {
			-- note: the name field of the dialog entry needs to be the same
			-- as the key for this to work at all.
			rndlabel:  { class: "label",    x: 7, y: 1, width: 3,  height: 1,                                   label: "Rounding" }
			xpos:      { class: "checkbox", x: 0, y: 2, width: 1,  height: 1, config: true, name:  "xpos",      label: "&x",            value: true,   hint: "Apply x position data to the selected lines." }
			ypos:      { class: "checkbox", x: 1, y: 2, width: 1,  height: 1, config: true, name:  "ypos",      label: "&y",            value: true,   hint: "Apply y position data to the selected lines." }
			origin:    { class: "checkbox", x: 2, y: 2, width: 2,  height: 1, config: true, name:  "origin",    label: "&Origin",       value: false,  hint: "Move the origin along with the position." }
			clip:      { class: "checkbox", x: 4, y: 2, width: 2,  height: 1, config: true, name:  "clip",      label: "&Clip",         value: false,  hint: "Move clip along with the position (note: will also be scaled and rotated if those options are selected)." }
			scale:     { class: "checkbox", x: 0, y: 3, width: 2,  height: 1, config: true, name:  "scale",     label: "&Scale",        value: true,   hint: "Apply scaling data to the selected lines." }
			border:    { class: "checkbox", x: 2, y: 3, width: 2,  height: 1, config: true, name:  "border",    label: "&Border",       value: true,   hint: "Scale border with the line (only if Scale is also selected)." }
			shadow:    { class: "checkbox", x: 4, y: 3, width: 2,  height: 1, config: true, name:  "shadow",    label: "&Shadow",       value: true,   hint: "Scale shadow with the line (only if Scale is also selected)." }
			blur:      { class: "checkbox", x: 4, y: 4, width: 2,  height: 1, config: true, name:  "blur",      label: "Bl&ur",         value: true,   hint: "Scale blur with the line (only if Scale is also selected, does not scale \\be)." }
			rotation:  { class: "checkbox", x: 0, y: 4, width: 3,  height: 1, config: true, name:  "rotation",  label: "&Rotation",     value: false,  hint: "Apply rotation data to the selected lines." }
			posround:  { class: "intedit",  x: 7, y: 2, width: 3,  height: 1, config: true, name:  "posround",  min: 0, max: 5,         value: 2,      hint: "How many decimal places of accuracy the resulting positions should have." }
			sclround:  { class: "intedit",  x: 7, y: 3, width: 3,  height: 1, config: true, name:  "sclround",  min: 0, max: 5,         value: 2,      hint: "How many decimal places of accuracy the resulting scales should have (also applied to border, shadow, and blur)." }
			rotround:  { class: "intedit",  x: 7, y: 4, width: 3,  height: 1, config: true, name:  "rotround",  min: 0, max: 5,         value: 2,      hint: "How many decimal places of accuracy the resulting rotations should have." }
			relative:  { class: "checkbox", x: 4, y: 6, width: 3,  height: 1, config: true, name:  "relative",  label: "R&elative",     value: true,   hint: "Start frame should be relative to the line's start time rather than to the start time of all selected lines" }
			stframe:   { class: "intedit",  x: 7, y: 6, width: 3,  height: 1, config: true, name:  "stframe",                           value: 1,      hint: "Frame used as the starting point for the tracking data. \"-1\" corresponds to the last frame." }
			linear:    { class: "checkbox", x: 4, y: 7, width: 2,  height: 1, config: true, name:  "linear",    label: "Li&near",       value: false,  hint: "Use transforms and \\move to create a linear transition, instead of frame-by-frame." }
			sortd:     { class: "dropdown", x: 5, y: 0, width: 4,  height: 1, config: true, name:  "sortd",     label: "Sort lines by", value: "Default", items: { "Default", "Time" }, hint: "The order to sort the lines after they have been tracked." }
			sortlabel: { class: "label",    x: 1, y: 0, width: 4,  height: 1,               name:  "sortlabel", label: "      Sort Method:" }
			-- It is also possible to store non-visible options in a dialog
			-- table. However, it requires some boilerplate and isn't exactly
			-- pretty. The only reason to do something like this would be if
			-- you have a separate macro for modifying your configuration,
			-- like aegisub-motion (used to have?). At that point, shit gets
			-- pretty weird, and doing this is extremely not recommended.
			autocopy:  { class: "label",    x: 0, y: 0,  width: 0,  height: 0, config: true, label: "", value: true }
			delsourc:  { class: "label",    x: 0, y: 0,  width: 0,  height: 0, config: true, label: "", value: false }
		}
		minimal: {
			field:  { value: true,  config: true }
			field2: { value: "two", config: true }
		}
	}

	buttons = {
		list: {
			"&Ok"
			"&Cancel"
		}
		namedList: {
			ok: "&Ok"
			cancel: "&Cancel"
		}
	}

	-- initialize configuration
	configuration = ConfigHandler interface, "ConfigHandlerTest.json"
	-- load previously serialized configuration from disk
	configuration\read!
	-- update the interface fields with the configuration that was just read.
	configuration\updateInterface!

	-- display the interface
	button, result = aegisub.dialog.display interface.main, buttons.list, buttons.namedList

	if button == buttons.namedList.ok

		-- update the stored configuration with the results from the dialog
		configuration\updateConfiguration result, "main"

		for key, value in pairs configuration.configuration
			log.warn "Section: #{key}"
			for name, val in pairs value
				log.warn "#{name} = #{val} = #{result[name]}"

		-- serialize the newly updated configuration to disk for next time.
		configuration\write!

aegisub.register_macro "#{project_name}/#{script_name}", script_description, testConfigHandler
