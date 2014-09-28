-- See LICENSE for more info about your rights as a person to be
-- rightfully persecuted

export script_name        = "Aegisub-Motion"
export script_description = "A set of tools for simplifying the process of creating and applying motion tracking data with Aegisub."
export script_author      = "torque"
export script_version     = "1.0.0-test9"

local interface

ffi            = require 'ffi'
clipboard      = require 'clipboard'
LineCollection = require 'a-mo.LineCollection'
ConfigHandler  = require 'a-mo.ConfigHandler'
DataWrapper    = require 'a-mo.DataWrapper'
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
			absPos:    { class: "checkbox", x: 4, y: 7,  width: 2,  height: 1, config: true, name: "absPos",    label: "&Absolute",     value: false, hint: "Set position to exactly that of the tracking data with no processing." }

			xScale:    { class: "checkbox", x: 0, y: 8,  width: 2,  height: 1, config: true, name: "xScale",    label: "&Scale",        value: true,  hint: "Apply scaling data to the selected lines." }
			border:    { class: "checkbox", x: 2, y: 8,  width: 2,  height: 1, config: true, name: "border",    label: "&Border",       value: true,  hint: "Scale border with the line (only if Scale is also selected)." }
			shadow:    { class: "checkbox", x: 4, y: 8,  width: 2,  height: 1, config: true, name: "shadow",    label: "&Shadow",       value: true,  hint: "Scale shadow with the line (only if Scale is also selected)." }
			blur:      { class: "checkbox", x: 4, y: 9,  width: 2,  height: 1, config: true, name: "blur",      label: "Bl&ur",         value: true,  hint: "Scale blur with the line (only if Scale is also selected, does not scale \\be)." }

			zRotation: { class: "checkbox", x: 0, y: 9,  width: 3,  height: 1, config: true, name: "zRotation", label: "&Rotation",     value: false, hint: "Apply rotation data to the selected lines." }

			rndLabel:  { class: "label",    x: 7, y: 6,  width: 3,  height: 1,                                  label: "Rounding" }
			posRound:  { class: "intedit",  x: 7, y: 7,  width: 3,  height: 1, config: true, name: "posRound",  min: 0, max: 5,         value: 2,     hint: "How many decimal places of accuracy the resulting positions should have (also applied to origin)." }
			sclRound:  { class: "intedit",  x: 7, y: 8,  width: 3,  height: 1, config: true, name: "sclRound",  min: 0, max: 5,         value: 2,     hint: "How many decimal places of accuracy the resulting scales should have (also applied to border, shadow, and blur)." }
			rotRound:  { class: "intedit",  x: 7, y: 9,  width: 3,  height: 1, config: true, name: "rotRound",  min: 0, max: 5,         value: 2,     hint: "How many decimal places of accuracy the resulting rotations should have." }

			writeConf: { class: "checkbox", x: 0, y: 11, width: 4,  height: 1, config: true, name: "writeConf", label: "&Write config", value: true,  hint: "Write current settings to the configuration file." }
			relative:  { class: "checkbox", x: 4, y: 11, width: 3,  height: 1, config: true, name: "relative",  label: "R&elative",     value: true,  hint: "Start frame should be relative to the beginning of the selection rather than the beginning of the video." }
			startFrame:{ class: "intedit",  x: 7, y: 11, width: 3,  height: 1, config: true, name: "startFrame",                        value: 1,     hint: "Frame used as the starting point for the tracking data. \"-1\" corresponds to the last frame." }
			linear:    { class: "checkbox", x: 4, y: 12, width: 2,  height: 1, config: true, name: "linear",    label: "Li&near",       value: false, hint: "Use transforms and \\move to create a linear transition, instead of frame-by-frame." }
			clipOnly:  { class: "checkbox", x: 0, y: 12, width: 3,  height: 1, config: true, name: "clipOnly",  label: "&Clip Only",    value: false, hint: "Only apply the main data to \\clips present in the line." }

			rectClip:  { class: "checkbox", x: 0, y: 10, width: 3,  height: 1, config: true, name: "rectClip",  label: "Rect C&lip",    value: true,  hint: "Apply tracking data to the rectangular clip contained in the line." }
			vectClip:  { class: "checkbox", x: 3, y: 10, width: 3,  height: 1, config: true, name: "vectClip",  label: "&Vect Clip",    value: true,  hint: "Apply tracking data to the vector clip contained in the line." }
			killTrans: { class: "checkbox", x: 6, y: 10, width: 3,  height: 1, config: true, name: "killTrans", label: "Interp. &transforms", value: true, hint: "Attempt to interpolate transform value instead of just shifting transform times." }

			-- delsourc:  { class: "label",    x: 0, y: 0,  width: 0,  height: 0, config: true, label: "", value: false }
		}
		clip: {
			-- mnemonics: xySRe + GCA
			dataLabel: { class: "label",    x: 0, y: 0, width: 10, height: 1, label:  "                     This stuff is for clips." }
			data:      { class: "textbox",  x: 0, y: 1, width: 10, height: 4,               name:  "data", hint: "Paste data or the path to a file containing it. No quotes or escapes." }

			optLabel:  { class: "label",    x: 0, y: 5, width: 5,  height: 1, label: "Data to be applied:" }
			xPosition: { class: "checkbox", x: 0, y: 6, width: 1,  height: 1, config: true, name: "xPosition",  label: "&x",            value: true,  hint: "Apply x position data to the selected clips in the selected lines." }
			yPosition: { class: "checkbox", x: 1, y: 6, width: 1,  height: 1, config: true, name: "yPosition",  label: "&y",            value: true,  hint: "Apply y position data to the selected clips in the selected lines." }
			xScale:    { class: "checkbox", x: 0, y: 7, width: 2,  height: 1, config: true, name: "xScale",     label: "&Scale",        value: true,  hint: "Apply scaling data to the selected clips in the selected lines." }
			zRotation: { class: "checkbox", x: 0, y: 8, width: 3,  height: 1, config: true, name: "zRotation",  label: "&Rotation",     value: false, hint: "Apply rotation data to the selected clips in the selected lines." }

			rectClip:  { class: "checkbox", x: 0, y: 10, width: 3,  height: 1, config: true, name: "rectClip",  label: "Rect C&lip",    value: true,  hint: "Apply tracking data to the rectangular clip contained in the line." }
			vectClip:  { class: "checkbox", x: 3, y: 10, width: 3,  height: 1, config: true, name: "vectClip",  label: "&Vect Clip",    value: true,  hint: "Apply tracking data to the vector clip contained in the line." }

			startLabel:{ class: "label",    x: 7, y: 5, width: 3,  height: 1, label: "Start Frame:" }
			startFrame:{ class: "intedit",  x: 7, y: 6, width: 3,  height: 1, config: true, name:  "startFrame",                        value: 1,     hint: "Frame used as the starting point for the tracking data. \"-1\" corresponds to the last frame." }
		}
		trim: {
			pLabel:   { class: "label", x: 0, y: 0, width: 10, height: 1, label: [[
Prefix the encoded video is written. Useful values are ?video for the
directory of the currently loaded video and ?script for the directory
of the currently open script. Can be a hardcoded path, too.]] }
			psLabel:  { class: "label", x: 0, y: 3, width: 10, height: 1, label: [[
Encoding preset. Different presets may have different output.]] }
			eLabel:   { class: "label", x: 0, y: 5, width: 10, height: 1, label: [[
The full path to your encoding binary (e.g. C:\x264.exe if you're
using the x264 preset).]] }
			cLabel:   { class: "label", x: 0, y: 7, width: 10, height: 1, label: [[
If you want to use a custom encoding command, write it here. If a
custom command is set, it overrides using a default.]] }
			prefix:   { config: true, value: "?video", class: "textbox",  x: 0, y: 1,  width: 10, height: 1, name: "prefix",                                                                hint: "Prefix the encoded video is written. Useful values are ?video for the directory of the currently loaded video and ?script for the directory of the currently open script." }
			makePfix: { config: true, value: false,    class: "checkbox", x: 0, y: 2, width: 10, height: 1, name: "makePfix",  label: "Try to create prefix directory.",                   hint: "Try to create prefix directory." }
			preset:   { config: true, value: "x264",   class: "dropdown", x: 0, y: 4,  width: 10, height: 1, name: "preset",    label: "Sort lines by", items: TrimHandler.existingPresets, hint: "Choose an existing preset by name." }
			encBin:   { config: true, value: "",       class: "textbox",  x: 0, y: 6,  width: 10, height: 1, name: "encBin",                                                                hint: "The full path to your encoding binary (x264.exe if you're using the default preset)" }
			command:  { config: true, value: "",       class: "textbox",  x: 0, y: 8,  width: 10, height: 4, name: "command",                                                               hint: "If you want to use a custom encoding command, write it here." }
		}
	}

fetchDataFromClipboard = ->
	-- According to vague reports, Aegisub clipboard usage crashes it on
	-- Linux. Disable any clipboard use until I find a better way to
	-- handle this.
	if ffi.os != "Linux"
		-- If there's nothing on the clipboard, clipboard.get returns nil.
		return clipboard.get! or ""

prepareConfig = ( config, mainData, clipData, lineCollection ) ->
	rectClipData, vectClipData = nil, nil

	totalFrames = lineCollection.totalFrames

	for field, data in pairs { main: mainData, clip: clipData }
		configField = config[field]

		if '' == configField.data or nil == configField.data
			for option in pairs configField
				-- Nuke everything because it doesn't matter at this point.
				configField[option] = false

		else
			-- Be extremely lazy and just re-parse data from scratch.
			unless data\bestEffortParsingAttempt configField.data
				log.windowError "You put something in the data box\nbut it is wrong in ways I can't imagine."
			unless data.dataObject\checkLength totalFrames
				log.windowError "The length of your #{field} data (#{data.length}) doesn't match\nthe length of your lines (#{totalFrames}) and I quit."

			if data.type == 'SRS'
				data.dataObject\createDrawings lineCollection.meta.PlayResY

			if configField.rectClip
				rectClipData = data
			if configField.vectClip
				vectClipData = data

	unless config.main.data or config.clip.data
		log.windowError "As far as I can tell, you've forgotten to give me any motion data."

	-- Disable options that depend on scale.
	unless config.main.xScale
		config.main.border = false
		config.main.shadow = false
		config.main.blur   = false

	-- Nudge the start frames.
	if config.main.relative
		for context in *{ 'main', 'clip' }
			-- Have to check that the field exists (if the clip dialog wasn't
			-- opened it will be nil) to avoid comparison with nil errors.
			if config[context].startFrame
				if config[context].startFrame == 0
					config[context].startFrame = 1
				elseif config[context].startFrame < 0
					config[context].startFrame = totalFrames + config[context].startFrame + 1
	else
		for context in *{ 'main', 'clip' }
			if config[context].startFrame
				config[context].startFrame = config[context].startFrame - lineCollection.startFrame + 1
				if config[context].startFrame <= 0
					log.windowError "You have specified an out-of-range absolute\nstart frame and you have been judged."

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
	setProgress = aegisub.progress.set
	setProgress 0

	totalLines = #lineCollection.lines

	options = lineCollection.options
	-- remove the lines while ensuring new lines will be inserted in the
	-- correct place.
	lineCollection\deleteWithShift!

	-- Perform all of the manipulation that used to be performed in
	-- Line.moon but are actually fairly Aegisub-Motion specific.
	lineCollection\runCallback ( line, index ) =>

		-- Add our signature extradata.
		line\setExtraData 'a-mo', { originalText: line.text, uuid: Math.uuid! }

		-- Get default style properties (will be used later if transform
		-- interpolation is enabled)
		line\getPropertiesFromStyle!

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
			tagBlock\gsub "\\org%([%.%d%-]+,[%.%d%-]+%)", ->
				@hasOrg = true
				return nil

			tagBlock\gsub "\\r([^\\}]*)", ( resetStyle ) ->
				styleTable = styles[resetStyle] or lineStyle
				tagBlock = appendMissingTags tagBlock, options, styleTable

			return tagBlock\gsub "(\\i?clip%b())", ( clip ) ->
				@hasClip = true
				return convertClipToFP clip

		setProgress index/totalLines

postprocLines = ( lineCollection ) ->
	setProgress = aegisub.progress.set
	setProgress 0

	totalLines = #lineCollection.lines

	lineCollection\runCallback ( line, index ) =>
		if line.wasLinear
			line\dontTouchTransforms!
		else
			if lineCollection.options.main.killTrans
				line\interpolateTransforms!
			else
				line\detokenizeTransforms!

		setProgress index/totalLines

	-- No progress for this.
	lineCollection\combineIdenticalLines!

applyProcessor = ( subtitles, selectedLines ) ->
	setTask = aegisub.progress.task

	setTask "Loading Interface"
	initializeInterface!

	math.randomseed tonumber tostring( os.time! )\reverse!\sub( 1, 8 )

	-- Initialize the configuration
	options = ConfigHandler interface, "aegisub-motion.json", true, script_version
	options\read!
	options\updateInterface { "main", "clip" }

	lineCollection = LineCollection subtitles, selectedLines

	currentVideoFrame = aegisub.project_properties!.video_position

	rawInputData = fetchDataFromClipboard!

	-- Instantiate both of these so they can be passed by reference later.
	setTask "Checking Clipboard for Data"
	mainData = DataWrapper!
	clipData = DataWrapper!
	if mainData\bestEffortParsingAttempt rawInputData
		if mainData.dataObject\checkLength lineCollection.totalFrames
			interface.main.data.value = rawInputData
			interface.main.dataLabel.label = "                Data is the correct length."
		else
			interface.main.dataLabel.label = "Data was the wrong length. Exp: #{lineCollection.totalFrames} Act: #{mainData.length}"

	if options.configuration.main.relative
		relativeFrame = currentVideoFrame - lineCollection.startFrame + 1
		if relativeFrame > 0 and relativeFrame <= lineCollection.totalFrames
			interface.main.startFrame.value = relativeFrame
			interface.clip.startFrame.value = relativeFrame
	else
		interface.main.startFrame.value = currentVideoFrame
		interface.clip.startFrame.value = currentVideoFrame

	setTask "Launching Interface"

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

	-- Update the persistent configuration before it gets (potentially)
	-- horribly mutilated in prepareConfig. Ensures that what the user saw
	-- last is what will be presented to them next time.
	if config.main.writeConf
		setTask "Updating Configuration"
		options\updateConfiguration config, { "main", "clip" }
	if config.main.writeConf or (options.configuration.main.writeConf != config.main.writeConf)
		options.configuration.main.writeConf = config.main.writeConf
		options\write!

	setTask "Preparing Configuration and Data"
	rectClipData, vectClipData = prepareConfig config, mainData, clipData, lineCollection
	lineCollection.options = config


	setTask "Preprocessing Lines"
	prepareLines lineCollection

	if mainData.type and 'SRS' != mainData.type
		mainData.dataObject\addReferenceFrame config.main.startFrame
		mainData.dataObject\stripFields config.main
	if clipData.type and 'SRS' != clipData.type
		clipData.dataObject\addReferenceFrame config.clip.startFrame
		clipData.dataObject\stripFields config.clip

	setTask "Applying Data"
	motionHandler = MotionHandler lineCollection, mainData, rectClipData, vectClipData
	newLines = motionHandler\applyMotion!

	-- Postproc lines: detokenize transforms and combine identical lines.
	setTask "Postprocessing Lines"
	postprocLines newLines
	newLines\replaceLines!

trimConfigDialog = ( options ) ->
	options\updateInterface "trim"
	button, config = aegisub.dialog.display interface.trim
	if button
		options\updateConfiguration config, "trim"
		options\write!
	else
		aegisub.cancel!

trimConfigurator = ->
	initializeInterface!
	options = ConfigHandler interface, "aegisub-motion.json", true, script_version
	options\read!
	trimConfigDialog options

trimProcessor = ( subtitles, selectedLines, activeLine, eachFlag ) ->
	initializeInterface!
	options = ConfigHandler interface, "aegisub-motion.json", true, script_version

	options\read!
	-- Check if encBin has been set.

	if options.configuration.trim.encBin == ""
		interface.trim.pLabel.label = [[
You must specify the path to your encoding binary.

]] .. interface.trim.pLabel.label
		trimConfigDialog options
	trim = TrimHandler options.configuration.trim
	if eachFlag
		seenRanges = { }
		for lineIndex in *selectedLines
			lineCollection = LineCollection subtitles, { lineIndex }
			collectionRange = "#{lineCollection.startFrame}-#{lineCollection.endFrame}"
			unless seenRanges[collectionRange]
				seenRanges[collectionRange] = true
				trim\calculateTrimLength lineCollection
				trim\performTrim!
	else
		lineCollection = LineCollection subtitles, selectedLines
		trim\calculateTrimLength lineCollection
		trim\performTrim!

	return selectedLines

trimProcessorEach = ( subtitles, selectedLines ) ->
	trimProcessor subtitles, selectedLines, nil, true

revertProcessor = ( subtitles, selectedLines ) ->
	setTask = aegisub.progress.task
	setProgress = aegisub.progress.set
	setTask "Collecting UUIDs"
	-- A table of all UUIDs found in the selected lines
	uuids = { }
	-- Indices of lines that need to be removed later (are part of a
	-- tracked line collection, but are not the first line in that
	-- collection)
	for index in *selectedLines
		with line = subtitles[index]
			if .extra['a-mo']
				data = json.decode .extra['a-mo']
				unless uuids[data.uuid]
					.text = data.originalText
					.number = index
					.extra = {}
					uuids[data.uuid] = line

	indicesToNuke = { }

	setTask "Gathering Matching Lines"
	totalLines = #subtitles

	for index = 1, totalLines
		with line = subtitles[index]
			if line.extra
				-- Catch lines containing our signature extradata.
				if .extra['a-mo']
					-- Decode our data, which is stored as json.
					data = json.decode .extra['a-mo']
					if uuids[data.uuid]
						oldLine = uuids[data.uuid]
						-- Check if we should change the start time.
						if .start_time < oldLine.start_time
							oldLine.start_time = .start_time
						-- Check if we should change the end time.
						if .end_time > oldLine.end_time
							oldLine.end_time = .end_time
						-- Mark the line for deletion.
						if index < oldLine.number
							oldLine.number = index
						elseif index > oldLine.number
							indicesToNuke[#indicesToNuke+1] = index

		setProgress index/totalLines

	setTask "Replacing Lines"
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
	revertProcessor

aegisub.register_macro "#{script_name}/Trim", "Cuts and encodes the current scene for use with motion tracking software.",
	trimProcessor, canRun

aegisub.register_macro "#{script_name}/Trim Each", "Cuts and encodes selected scenes for use with motion tracking software.",
	trimProcessorEach, canRun

aegisub.register_macro "#{script_name}/Trim Settings", "Sets options for the trim tool.",
	trimConfigurator
