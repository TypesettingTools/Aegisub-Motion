LineCollection = require 'a-mo.LineCollection'
log = require 'a-mo.Log'

project_name = "Aegisub-Motion"
export script_name = "Tests/LineCollection"
export script_description = "Tests LineCollection and Line classes."

ourLines = {
	defaults: {
		actor: "", class: "dialogue", comment: false, effect: "banner",
		start_time: 0, end_time: 1000, extra: {}, layer: 0,
		margin_l: 0, margin_r: 0, margin_t: 0, section: "[Events]"
		style: "Default"
		text: "Hi, I am a line."
	}

	theLines: {
		{ }
		{ start_time: 1000, end_time:2000
		  text: "{\\fad(150,300)}I am fading out of existence.{\\fad(150,305)}" }
		{ start_time: 2000, end_time:3000
		  text: "{\\t(\\1c&HFF0000&)}I {\\t(0,0,\\1c&H00FF00&)}am {\\t(2.345,\\1c&H0000FF&)}transforming." }
		{ start_time: 4000, end_time:5000
		  text: "We are Identical." }
		{ start_time: 3500, end_time:4000
		  text: "We are Identical." }
		{ start_time: 3000, end_time:3500
		  text: "We are Identical." }
		{ start_time: 5000, end_time:6000
		  text: '{\\pos(0,0)\\an7\\c&H000000&\\c&H0000FF&\\clip(80,185,425,247.5)}#{fullFrame}' }
		{ start_time: 6000, end_time:7000
		  text: '{\\pos(0,0)\\an7\\c&H000000&\\clip(3,m 80 185 l 320 212 425 247 45 244)}#{fullFrame}' }
	}

	iterator: =>
		i = 1
		n = #@theLines
		return ->
			if i <= n
				theLine = @theLines[i]
				i += 1
				for k,v in pairs @defaults
					theLine[k] = theLine[k] or v

				theLine.text = theLine.text\gsub "#%{fullFrame%}", ->
					@fullFrame!

				return theLine

	fullFrame: ->
		width, height = aegisub.video_size!
		("{\\p1}m 0 0 l %d 0 %d %d 0 %d{\\p0}")\format width, width, height, height
}


testLineCollection = ( subtitles, selectedLines, activeLine ) ->
	-- We're just going to insert our subtitles here because it's
	-- guaranteed to be valid.
	first = selectedLines[1]

	-- Generate our the lines to insert using the template.
	theLines = [ line for line in ourLines\iterator! ]

	-- Actually insert the lines.
	subtitles.insert first, unpack theLines

	-- "Select" the lines we just inserted by generating a table of their
	-- indices.
	newSelLines = [ i for i = first, #theLines + first - 1 ]

	-- Instantiate our LineCollection class.
	ourLineCollection = LineCollection subtitles, nil, newSelLines

	ourLineCollection\callMethodOnAllLines "deduplicateTags"

	-- Do an in-place replace of the lines we have just abused.
	ourLineCollection\replaceLines!

canRun = ( sub, sel ) ->
	if not aegisub.frame_from_ms 0
		return false, "You must have a video loaded to run this macro."
	elseif 0 == #sel
		return false, "You must have lines selected to use this macro."
	true

aegisub.register_macro "#{project_name}/#{script_name}", script_description, testLineCollection, canRun
