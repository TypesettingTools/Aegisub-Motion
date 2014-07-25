TrimHandler = require 'a-mo.TrimHandler'
LineCollection = require 'a-mo.LineCollection'
log = require 'a-mo.Log'

export script_name = "Test TrimHandler"
export script_description = "Tests TrimHandler class."

testTrimHandler = ( subtitles, selectedLines, activeLine ) ->
	trimSettings = {
		prefix: "?video/"
		encbin: "/usr/local/bin/x264"
		enccom: '"#{encbin}" --crf 16 --tune fastdecode -i 250 --fps 23.976 --sar 1:1 --index "#{prefix}#{index}.index" --seek #{startf} --frames #{lenf} -o "#{prefix}#{output}[#{startf}-#{endf}].mp4" "#{inpath}#{input}"'
		encpre: "x264"
	}

	ourLineCollection = LineCollection subtitles, selectedLines

	ourTrimHandler = TrimHandler trimSettings
	ourTrimHandler\calculateTrimLength ourLineCollection
	ourTrimHandler\performTrim!

isVideoLoaded = ->
	if aegisub.frame_from_ms 0
		return true
	else
		return false, "Validation failed: you don't have a video loaded."

aegisub.register_macro script_name, script_description, testTrimHandler, isVideoLoaded
