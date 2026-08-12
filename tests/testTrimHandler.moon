package.loaded['l0.DependencyControl'] = nil
package.preload['l0.DependencyControl'] = ->
	error 'DependencyControl is intentionally disabled by the test suite.'

TrimHandler = require 'a-mo.TrimHandler'
LineCollection = require 'a-mo.LineCollection'
log = require 'a-mo.Log'

project_name = "Aegisub-Motion"
export script_name = "Tests/TrimHandler"
export script_description = "Tests TrimHandler class."

testTrimHandler = ( subtitles, selectedLines, activeLine ) ->
	trimSettings = {
		prefix: "?video"
		preset: "ffmpeg"
		encBin: "ffmpeg"
		command: ""
		makePfix: false
		writeLog: false
	}

	ourLineCollection = LineCollection subtitles, selectedLines

	ourTrimHandler = TrimHandler trimSettings
	assert ourTrimHandler\calculateTrimLength(ourLineCollection), "a selected dialogue range must be trimmable"
	assert ourTrimHandler.tokens.startt == aegisub.ms_from_frame( ourLineCollection.startFrame ) / 1000,
		"startt must be derived from the selected video frame"
	assert ourTrimHandler.tokens.endt == aegisub.ms_from_frame( ourLineCollection.endFrame ) / 1000,
		"endt must be derived from the exclusive ending video frame"

	emptyLineCollection = LineCollection subtitles, selectedLines, -> false
	assert not ourTrimHandler\calculateTrimLength(emptyLineCollection), "an empty line collection must be skipped"

	selectedLines

canRun = ( sub, sel ) ->
	if not aegisub.frame_from_ms 0
		return false, "You must have a video loaded to run this macro."
	elseif 0 == #sel
		return false, "You must have lines selected to use this macro."
	true

aegisub.register_macro "#{project_name}/#{script_name}", script_description, testTrimHandler, canRun
