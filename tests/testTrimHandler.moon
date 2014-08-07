TrimHandler = require 'a-mo.TrimHandler'
LineCollection = require 'a-mo.LineCollection'
log = require 'a-mo.Log'

project_name = "Aegisub-Motion"
export script_name = "Tests/TrimHandler"
export script_description = "Tests TrimHandler class."

testTrimHandler = ( subtitles, selectedLines, activeLine ) ->
	trimSettings = {
		prefix: "?video/"
		encbin: "/usr/local/bin/x264"
		enccom: '"#{encbin}" --crf 16 --tune fastdecode -i 250 --fps 23.976 --sar 1:1 --index "#{prefix}#{index}.index" --seek #{startf} --frames #{lenf} -o "#{prefix}#{output}[#{startf}-#{endf}].mp4" "#{inpath}#{input}"'
		encpre: "x264"
	}

	otherTrimSettings = {
		prefix: "?video/"
		encbin: "/usr/local/bin/ffmpeg"
		encpre: "ffmpeg"
	}

	ourLineCollection = LineCollection subtitles, nil, selectedLines

	ourTrimHandler = TrimHandler trimSettings
	ourTrimHandler\calculateTrimLength ourLineCollection
	ourTrimHandler\performTrim!

	otherTrimHandler = TrimHandler otherTrimSettings
	otherTrimHandler\calculateTrimLength ourLineCollection
	-- otherTrimHandler\performTrim!

	selectedLines

canRun = ( sub, sel ) ->
	if not aegisub.frame_from_ms 0
		return false, "You must have a video loaded to run this macro."
	elseif 0 == #sel
		return false, "You must have lines selected to use this macro."
	true

aegisub.register_macro "#{project_name}/#{script_name}", script_description, testTrimHandler, canRun
