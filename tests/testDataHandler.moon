DataHandler = require 'a-mo.DataHandler'
log = require 'a-mo.Log'

export script_name = "Test DataHandler"
export script_description = "Tests DataHandler class."

oldStyleData = [=[
Adobe After Effects 6.0 Keyframe Data

	Units Per Second	23.976
	Source Width	1280
	Source Height	720
	Source Pixel Aspect Ratio	1
	Comp Pixel Aspect Ratio	1

Anchor Point
	Frame	X pixels	Y pixels	Z pixels
	301	631.721	60.102	0
	302	631.638	67.4154	0
	303	631.463	75.1229	0
	304	631.116	82.7084	0
	305	630.644	90.4096	0

Position
	Frame	X pixels	Y pixels	Z pixels
	301	631.721	60.102	0
	302	631.638	67.4154	0
	303	631.463	75.1229	0
	304	631.116	82.7084	0
	305	630.644	90.4096	0

Scale
	Frame	X percent	Y percent	Z percent
	301	199.755	199.755	100
	302	198.532	198.532	100
	303	197.401	197.401	100
	304	196.134	196.134	100
	305	194.921	194.921	100

Rotation
	Frame	Degrees
	301	-44.5743
	302	-44.0877
	303	-43.5508
	304	-43.035
	305	-42.5111

End of Keyframe Data
]=]

-- Mocha Pro 4.0.0 and above do not export the Anchor Point section.
newStyleData = [=[
Adobe After Effects 6.0 Keyframe Data

	Units Per Second	30
	Source Width	1280
	Source Height	720
	Source Pixel Aspect Ratio	1
	Comp Pixel Aspect Ratio	1

Position
	Frame	X pixels	Y pixels	Z pixels
	0	603	226.5	0
	1	579.816	228.624	0
	2	530.077	232.058	0
	3	491.327	233.435	0
	4	440.515	236.273	0

Scale
	Frame	X percent	Y percent	Z percent
	0	97.9498	97.9498	100
	1	98.0078	98.0078	100
	2	99.3704	99.3704	100
	3	99.2926	99.2926	100
	4	99.3238	99.3238	100

Rotation
	Frame	Degrees
	0	-2.8202e-05
	1	-0.291779
	2	0.113339
	3	-1.34251
	4	-1.14225

End of Keyframe Data
]=]

testDataHandler = ( subtitles, selectedLines, activeLine ) ->

	oldDataHandler = DataHandler oldStyleData
	newDataHandler = DataHandler newStyleData
	thirdDataHandler = DataHandler oldStyleData

	oldDataHandler\parse!
	newDataHandler\parse!
	thirdDataHandler\parse!
	thirdDataHandler\stripFields { "xPosition", "scale" }

	for _, dataHandler in ipairs { oldDataHandler, newDataHandler, thirdDataHandler }
		log.warn "\n#{dataHandler.width}, #{dataHandler.height}"
		for _, v in ipairs { "xPosition", "yPosition", "scale", "rotation" }
			log.warn v
			for _, val in ipairs dataHandler[v]
				log.warn "  #{val}"


aegisub.register_macro script_name, script_description, testDataHandler
