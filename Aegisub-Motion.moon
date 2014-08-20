-- See LICENSE for more info about your rights as a person to be
-- rightfully persecuted

export script_name        = "Aegisub-Motion"
export script_description = "A set of tools for simplifying the process of creating and applying motion tracking data with Aegisub."
export script_author      = "torque"
export script_version     = "0xDEADBEEF"

local interface

ffi            = require 'ffi'
clipboard      = require 'clipboard'
re             = require 'aegisub.re'
LineCollection = require 'a-mo.LineCollection'
ConfigHandler  = require 'a-mo.ConfigHandler'
DataHandler    = require 'a-mo.DataHandler'
MotionHandler  = require 'a-mo.MotionHandler'
TrimHandler    = require 'a-mo.TrimHandler'
Math           = require 'a-mo.Math'
log            = require 'a-mo.Log'
json           = require 'json'

initializeInterface = ->
	-- Set up interface tables.
	interface = {
		main: {
			-- mnemonics: xyOCSBuRWen + G\A + Wl\A
			dataLabel: { class: "label",    x: 0, y: 0,  width: 10, height: 1,                                  label: "                 Paste data or enter a filepath." }
			data:      { class: "textbox",  x: 0, y: 1,  width: 10, height: 4,               name: "data",                                            hint: "Paste data or the path to a file containing it. No quotes or escapes." }

			optLabel:  { class: "label",    x: 0, y: 6,  width: 5,  height: 1,                                  label: "Data to be applied:" }
			xPosition: { class: "checkbox", x: 0, y: 7,  width: 1,  height: 1, config: true, name: "xPosition", label: "&x",            value: true,  hint: "Apply x position data to the selected lines." }
			yPosition: { class: "checkbox", x: 1, y: 7,  width: 1,  height: 1, config: true, name: "yPosition", label: "&y",            value: true,  hint: "Apply y position data to the selected lines." }
			origin:    { class: "checkbox", x: 2, y: 7,  width: 2,  height: 1, config: true, name: "origin",    label: "&Origin",       value: false, hint: "Move the origin along with the position." }
			absPos:    { class: "checkbox", x: 4, y: 7,  width: 2,  height: 1, config: true, name: "absPos",    label: "&Absolute",     value: false, hint: "Move clip along with the position (note: will also be scaled and rotated if those options are selected)." }

			xScale:    { class: "checkbox", x: 0, y: 8,  width: 2,  height: 1, config: true, name: "xScale",    label: "&Scale",        value: true,  hint: "Apply scaling data to the selected lines." }
			border:    { class: "checkbox", x: 2, y: 8,  width: 2,  height: 1, config: true, name: "border",    label: "&Border",       value: true,  hint: "Scale border with the line (only if Scale is also selected)." }
			shadow:    { class: "checkbox", x: 4, y: 8,  width: 2,  height: 1, config: true, name: "shadow",    label: "&Shadow",       value: true,  hint: "Scale shadow with the line (only if Scale is also selected)." }
			blur:      { class: "checkbox", x: 4, y: 9,  width: 2,  height: 1, config: true, name: "blur",      label: "Bl&ur",         value: true,  hint: "Scale blur with the line (only if Scale is also selected, does not scale \\be)." }

			zRotation: { class: "checkbox", x: 0, y: 9,  width: 3,  height: 1, config: true, name: "zRotation", label: "&Rotation",     value: false, hint: "Apply rotation data to the selected lines." }

			rndLabel:  { class: "label",    x: 7, y: 6,  width: 3,  height: 1,                                  label: "Rounding" }
			posRound:  { class: "intedit",  x: 7, y: 7,  width: 3,  height: 1, config: true, name: "posRound",  min: 0, max: 5,         value: 2,     hint: "How many decimal places of accuracy the resulting positions should have (also applied to origin)." }
			sclRound:  { class: "intedit",  x: 7, y: 8,  width: 3,  height: 1, config: true, name: "sclRound",  min: 0, max: 5,         value: 2,     hint: "How many decimal places of accuracy the resulting scales should have (also applied to border, shadow, and blur)." }
			rotRound:  { class: "intedit",  x: 7, y: 9,  width: 3,  height: 1, config: true, name: "rotRound",  min: 0, max: 5,         value: 2,     hint: "How many decimal places of accuracy the resulting rotations should have." }

			writeConf: { class: "checkbox", x: 0, y: 11, width: 4,  height: 1,               name: "writeConf", label: "&Write config", value: false, hint: "Write current settings to the configuration file." }
			relative:  { class: "checkbox", x: 4, y: 11, width: 3,  height: 1, config: true, name: "relative",  label: "R&elative",     value: true,  hint: "Start frame should be relative to the line's start time rather than to the start time of all selected lines" }
			startFrame:{ class: "intedit",  x: 7, y: 11, width: 3,  height: 1, config: true, name: "startFrame",                        value: 1,     hint: "Frame used as the starting point for the tracking data. \"-1\" corresponds to the last frame." }
			linear:    { class: "checkbox", x: 4, y: 12, width: 2,  height: 1, config: true, name: "linear",    label: "Li&near",       value: false, hint: "Use transforms and \\move to create a linear transition, instead of frame-by-frame." }

			rectClip:  { class: "checkbox", x: 0, y: 10, width: 3,  height: 1, config: true, name: "rectClip",  label: "Rect Clip",     value: true,  hint: "Apply tracking data to the rectangular clip contained in the line." }
			vectClip:  { class: "checkbox", x: 3, y: 10, width: 3,  height: 1, config: true, name: "vectClip",  label: "Vect Clip",     value: true,  hint: "Apply tracking data to the vector clip contained in the line." }

			sortLabel: { class: "label",    x: 1, y: 5,  width: 4,  height: 1,               name: "sortlabel", label: "      Sort Method:" }
			sortd:     { class: "dropdown", x: 5, y: 5,  width: 4,  height: 1, config: true, name: "sortd",     label: "Sort lines by", value: "Default", items: { "Default", "Time" }, hint: "The order to sort the lines after they have been tracked." }
			-- autocopy:  { class: "label",    x: 0, y: 0,  width: 0,  height: 0, config: true, label: "", value: true }
			-- delsourc:  { class: "label",    x: 0, y: 0,  width: 0,  height: 0, config: true, label: "", value: false }
		}
		clip: {
			-- mnemonics: xySRe + GCA
			dataLabel: { class: "label",    x: 0, y: 0, width: 10, height: 1, label:  "                     This stuff is for clips." }
			data:      { class: "textbox",  x: 0, y: 1, width: 10, height: 4,               name:  "data", hint: "Paste data or the path to a file containing it. No quotes or escapes." }

			optLabel:  { class: "label",    x: 0, y: 5, width: 5,  height: 1, label: "Data to be applied:" }
			xPosition: { class: "checkbox", x: 0, y: 6, width: 1,  height: 1, config: true, name: "xPosition", value: true,  label: "&x", hint: "Apply x position data to the selected lines." }
			yPosition: { class: "checkbox", x: 1, y: 6, width: 1,  height: 1, config: true, name: "yPosition", value: true,  label: "&y", hint: "Apply y position data to the selected lines." }
			xScale:    { class: "checkbox", x: 0, y: 7, width: 2,  height: 1, config: true, name: "xScale",    value: true,  label: "&Scale" }
			zRotation: { class: "checkbox", x: 0, y: 8, width: 3,  height: 1, config: true, name: "zRotation", value: false, label: "&Rotation" }

			rectClip:  { class: "checkbox", x: 0, y: 10, width: 3,  height: 1, config: true, name: "rectClip",  label: "Rect Clip",     value: true,  hint: "Apply tracking data to the rectangular clip contained in the line." }
			vectClip:  { class: "checkbox", x: 3, y: 10, width: 3,  height: 1, config: true, name: "vectClip",  label: "Vect Clip",     value: true,  hint: "Apply tracking data to the vector clip contained in the line." }

			startLabel:{ class: "label",    x: 7, y: 5, width: 3,  height: 1, label: "Start Frame:" }
			startFrame:{ class: "intedit",  x: 7, y: 6, width: 3,  height: 1, config: true, name:  "startFrame",  value: 1 }
		}
		trim: {
			prefix:  { config: true, value: "?video/" }
			preset:  { config: true, value: "x264" }
			encbin:  { config: true, value: "" }
			command: { config: true, value: "" }
		}
	}

fetchDataFromClipboard = ->
	-- According to vague reports, Aegisub clipboard usage crashes it on
	-- Linux. Disable any clipboard use until I find a better way to
	-- handle this.
	if ffi.os != "Linux"
		-- If there's nothing on the clipboard, clipboard.get returns nil.
		return clipboard.get!

prepareConfig = ( config, mainData, clipData, totalFrames ) ->
	rectClipData, vectClipData = nil, nil

	if config.main.data == ''
		for option in pairs config.main
			-- Nuke everything because it doesn't matter at this point.
			config.main[option] = false

	else
		-- Be extremely lazy and just re-parse data from scratch.
		unless mainData\parseRawDataString config.main.data
			unless mainData\parseFile config.main.data
				log.windowError "You put something in the data box\nbut it is wrong in ways I can't imagine."

		if config.main.rectClip
			rectClipData = mainData
		if config.main.vectClip
			vectClipData = mainData

	if config.clip.data == '' or config.clip.data == nil
		unless config.main.data
			log.windowError "You have failed to provide any tracking\ndata, as far as I can tell."

		for option in pairs config.clip
			config.clip[option] = false

	else
		unless clipData\parseRawDataString config.clip.data
			unless clipData\parseFile config.clip.data
				log.windowError "You put something in the data box\nbut it is wrong in ways I can't imagine."

		if config.clip.rectClip
			rectClipData = clipData
		if config.clip.vectClip
			vectClipData = clipData

	-- Disable options that depend on scale.
	unless config.main.xScale
		config.main.border = false
		config.main.shadow = false
		config.main.blur   = false

	-- Nudge the start frames.
	for context in *{ 'main', 'clip' }
		if config[context].startFrame
			if config[context].startFrame == 0
				config[context].startFrame = 1
			elseif config[context].startFrame < 0
				config[context].startFrame = totalFrames - config[context].startFrame + 1

	if rectClipData or vectClipData
		config.main.linear = false

	return rectClipData, vectClipData


-- This table is used to verify that style defaults are inserted at
-- the beginning the selected line(s) if the corresponding options are
-- selected. The structure is: [tag] = { opt:"opt", key:"style key",
-- skip:val } where "opt" is the option that must be enabled, "style
-- key" is the key to get the value from the style, and skip specifies
-- not to write the tag if the style default is that value.
importantTags = {
	"\\fscx": { opt: "xScale",    key: "scale_x", skip: 0 }
	"\\fscy": { opt: "xScale",    key: "scale_y", skip: 0 }
	"\\bord": { opt: "border",    key: "outline", skip: 0 }
	"\\shad": { opt: "shadow",    key: "shadow",  skip: 0 }
	"\\frz":  { opt: "zRotation", key: "angle" }
}

-- A style table is passed to this function so that it can cope with
-- \r.
appendMissingTags = ( block, options, styleTable ) ->
	block = block\sub 1, -2
	for tag, tab in pairs importantTags
		if options[tab.opt]
			if not block\match tag .. "[%-%d%.]+"
				styleDefault = styleTable[tab.key]
				if tonumber( styleDefault ) != tab.skip
					block ..= tag .. ("%g")\format styleDefault
	return block .. "}"

convertClipToFP = ( clip ) ->
	-- only muck around with vector clips (convert scaling factor into floating point coordinates).
	unless clip\match "[%-%d%.]+, *[%-%d%.]+"
		-- Convert clip with scale into floating point coordinates.
		clip = clip\gsub "%((%d*),?(.-)%)", ( scaleFactor, points ) ->
			if scaleFactor ~= ""
				scaleFactor = tonumber scaleFactor

				points = points\gsub "([%.%d%-]+) ([%.%d%-]+)", ( x, y ) ->
					x = Math.round tonumber( x )/(2^(scaleFactor - 1)), 2
					y = Math.round tonumber( y )/(2^(scaleFactor - 1)), 2

					("%g %g")\format x, y
			return '(' .. points .. ')'
	return clip

fadToTransform = ( fadStart, fadEnd, alpha, value, lineDuration ) ->
	str = ""
	if fadStart > 0
		str = ("%s&HFF&\\t(%d,%s,%s%s)")\format alpha, 0, fadStart, alpha, value
	if fadEnd > 0
		str ..= ("\\t(%d,%d,%s&HFF&)")\format lineDuration - fadEnd, lineDuration, alpha
	str

prepareLines = ( lineCollection ) ->
	options = lineCollection.options
	-- remove the lines while ensuring new lines will be inserted in the
	-- correct place.
	lineCollection\deleteWithShift!

	-- Perform all of the manipulation that used to be performed in
	-- Line.moon but are actually fairly Aegisub-Motion specific.
	lineCollection\runCallback ( line ) =>

		-- Add our signature extradata.
		line\setExtraData 'a-mo', { originalText: line.text, uuid: Math.uuid! }

		-- need to brutalize fades before tokenizing transforms so that the
		-- produced transforms will be tokenized as well. Alternately (this
		-- may be more clean but also less efficient), tokenize transforms,
		-- dedup tags, detokenize transforms, brutalize fades, and then
		-- retokenize transforms.
		fadWasFound = false
		fadStart, fadEnd = 0, 0
		line\runCallbackOnOverrides ( tagBlock ) =>
			return tagBlock\gsub "\\fad%((%d+),(%d+)%)", ( start, finish ) ->
				unless fadWasFound
					fadStart = tonumber start
					fadEnd   = tonumber finish
					fadWasFound = true
				return ""

		if fadWasFound
			line\runCallbackOnOverrides ( tagBlock ) =>
				return tagBlock\gsub "(\\[1234]?a[lpha]-)(&H%x%x&)", ( alpha, value ) ->
					return fadToTransform fadStart, fadEnd, alpha, value, @duration

			line\runCallbackOnFirstOverride ( tagBlock ) =>
				return "{" .. fadToTransform( fadStart, fadEnd, "\\alpha", "&H00&", @duration ) .. tagBlock\sub 2

		-- Tokenize the transforms to simplify later processing.
		line\tokenizeTransforms!

		-- Deduplicate all override tags.
		line\deduplicateTags!

		-- Collect alignment and position info for each line.
		styles = @styles
		lineStyle = line.styleRef
		unless line\extraMetrics lineStyle
			line\ensureLeadingOverrideBlockExists

			-- Note that we are repeatedly shadowing @, so in this function it
			-- refers to the line. This is interestingly the opposite of how
			-- fat arrow functions work in coffeescript.
			line\runCallbackOnFirstOverride ( tagBlock ) =>
				return tagBlock\gsub "{", ("{\\pos(%g,%g)")\format @xPosition, @yPosition


		-- Add any tags we need that are missing from the line.
		line\runCallbackOnFirstOverride ( tagBlock ) =>
			return appendMissingTags tagBlock, options.main, lineStyle

		line\runCallbackOnOverrides ( tagBlock ) =>
			tagBlock\gsub "\\r([^\\}]*)", ( resetStyle ) ->
				styleTable = styles[resetStyle] or lineStyle
				tagBlock = appendMissingTags tagBlock, options, styleTable

			return tagBlock\gsub "(\\i?clip%b())", ( clip ) ->
				@hasClip = true
				return convertClipToFP clip

postprocLines = ( lineCollection ) ->
	lineCollection\runCallback ( line ) =>
		line\detokenizeTransforms!

	lineCollection\combineIdenticalLines!

applyProcessor = ( subtitles, selectedLines ) ->

	initializeInterface!

	math.randomseed tonumber tostring( os.time! )\reverse!\sub( 1, 8 )

	-- Initialize the configuration
	options = ConfigHandler interface, "aegisub-motion.json", true, script_version
	options\read!
	options\updateInterface { "main", "clip" }

	lineCollection = LineCollection subtitles, selectedLines
	lineCollection.options = options.configuration

	currentVideoFrame = aegisub.project_properties!.video_position

	rawInputData = fetchDataFromClipboard!

	mainData = DataHandler!
	clipData = DataHandler!
	if rawInputData
		unless mainData\parseRawDataString rawInputData
			mainData\parseFile rawInputData
		if mainData.length
			if mainData\checkLength lineCollection
				interface.main.data.value = rawInputData
				interface.main.dataLabel.label = "            Clipboard data is the correct length."
			else
				interface.main.dataLabel.label = "Clipboard data was the wrong length. E: #{lineCollection.totalFrames} A: #{mainData.length}"

	relativeFrame = currentVideoFrame - lineCollection.startFrame + 1
	if relativeFrame > 0 and relativeFrame <= lineCollection.totalFrames
		interface.main.startFrame.value = relativeFrame
		interface.clip.startFrame.value = relativeFrame

	-- cancel:Abort in the main dialog tells Esc key to abort the entire macro
	-- cancel:Back in \clip dialog tells Esc key to close it and go back to the main dialog
	buttons = {
		main: {
			list: {
				"&Go"
				"Track &\\clip separately"
				"&Abort"
			}
			namedList: {
				ok: "&Go"
				clip: "Track &\\clip separately"
				cancel: "&Abort"
			}
		}
		clip: {
			list: {
				"&Go"
				"&Back"
				"&Abort"
			}
			namedList: {
				ok: "&Go"
				close: "&Back"
				abort: "&Abort"
			}
		}
	}

	currentDialog = "main"
	config = { clip: { }, main: { } }

	while true
		button, config[currentDialog] = aegisub.dialog.display interface[currentDialog], buttons[currentDialog].list, buttons[currentDialog].namedList

		for k, v in pairs config[currentDialog]
			interface[currentDialog][k].value = v

		switch button
			when buttons.main.namedList.clip
				currentDialog = "clip"

			when false, buttons.clip.namedList.abort
				aegisub.progress.task "ABORT"
				aegisub.cancel!

			when buttons.clip.namedList.close
				currentDialog = "main"

			else
				log.debug tostring button
				break

	prepareConfig config, mainData, clipData, lineCollection.totalFrames
	prepareLines lineCollection

	options\updateConfiguration config, { "main", "clip" }
	options\write!

	mainData\addReferenceFrame options.configuration.main.startFrame
	mainData\stripFields options.configuration.main

	motionHandler = MotionHandler lineCollection, mainData, clipData
	newLines = motionHandler\applyMotion!

	-- Clean up lines: detokenize transforms and combine identical lines.
	postprocLines newLines
	newLines\replaceLines!

applyTrim = ( subtitles, selectedLines ) ->
	initializeInterface!
	options = ConfigHandler interface, "aegisub-motion.json", true, script_version
	options\read!
	lineCollection = LineCollection subtitles, nil, selectedLines
	trim = TrimHandler options.trim
	trim\calculateTrimLength lineCollection
	trim\performTrim!

revertProcessor = ( subtitles, selectedLines ) ->
	-- A table of all UUIDs found in the selected lines
	uuids = { }
	-- Indices of lines that need to be removed later (are part of a
	-- tracked line collection, but are not the first line in that
	-- collection)
	indicesToNuke = { }
	-- Loop across all selected lines.
	for index in *selectedLines
		line = subtitles[index]
		-- Catch lines containing our signature extradata.
		if line.extra['a-mo']
			-- Decode our data, which is stored as json.
			data = json.decode line.extra['a-mo']
			if uuids[data.uuid]
				oldLine = uuids[data.uuid]
				-- Check if we should change the start time.
				if line.start_time < oldLine.start_time
					oldLine.start_time = line.start_time
				-- Check if we should change the end time.
				if line.end_time > oldLine.end_time
					oldLine.end_time = line.end_time
				-- Mark the line for deletion.
				indicesToNuke[#indicesToNuke+1] = index

			else
				-- If a line has a new UUID then add it to the table.
				line.text = data.originalText
				line.number = index
				line.extra = {}
				uuids[data.uuid] = line

	-- Replace the lines.
	for _, line in pairs uuids
		subtitles[line.number] = line

	-- Delete the remainders.
	subtitles.delete indicesToNuke

canRun = ( sub, selectedLines ) ->
	if not aegisub.frame_from_ms 0
		return false, "You must have a video loaded to run this macro."
	elseif 0 == #selectedLines
		return false, "You must have lines selected to use this macro."
	true

aegisub.register_macro "#{script_name}/Apply", "Applies properly formatted motion tracking data to selected subtitles.",
	applyProcessor, canRun

aegisub.register_macro "#{script_name}/Revert", "Removes properly formatted motion tracking data from selected subtitles.",
	revertProcessor, canRun

aegisub.register_macro "#{script_name}/Trim", "Cuts and encodes the current scene for use with motion tracking software.",
	applyTrim, canRun
