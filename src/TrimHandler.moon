class TrimHandler

	windows: aegisub.decode_path( "/" ) ~= "/"

	tokens: {
		encbin: true
		enccom: true
		prefix: true
		inpath: true
		input:  true
		index:  true
		output: true
		nl:     "\n"
		startt: 0
		endt:   0
		lent:   0
		startf: 0
		endf:   0
		lenf:   0
	}

	-- trimConfig is just the trim subtable of the config table collection.
	new: ( trimConfig ) =>
		with @tokens
			.encbin = trimConfig.encbin
			.enccom = trimConfig.enccom
			.prefix = trimConfig.prefix
			.inpath = aegisub.decode_path "?video/"

	calculateTrimLength: ( lineCollection ) =>
		with @tokens
			.startt = lineCollection.startTime
			.endt   = lineCollection.endTime
			.lent   = .endt - .startt
			.startf = lineCollection.startFrame
			.endf   = lineCollection.endFrame
			.lenf   = lineCollection.totalFrames

	getVideoName: ( sub ) =>
		with @tokens
			if aegisub.project_properties
				video = aegisub.project_properties!.video_file
				windowerr video\len! ~= 0, "Theoretically it should be impossible to get this error."
				.input = video\sub .inpath\len! + 1
			else
				for x = 1, #sub
					if sub[x].key == "Video File"
						.input = sub[x].value\gsub("^ ", "")\gsub("[A-Z]:\\", "")\gsub(".+[^\\/]-[\\/]", "")
						return
				windowerr false, "Could not find 'Video File'. Try saving your script before rerunning the macro."

	performTrim: =>
		with platform = ({
				[true]:  {
					pre: os.getenv('TEMP')
					ext: ".bat"
					exec: '""%s""'
					postExec: "\nif errorlevel 1 (echo Error & pause)"
					execFunc: ( encodeScript ) ->
						os.execute encodeScript
				}
				[false]: {
					pre: "/tmp"
					ext: ".sh"
					exec: 'sh "%s"'
					postExec: " 2>&1"
					execFunc: ( encodeScript ) ->
						output = io.popen encodeScript
						debug output\read '*a'
						output\close!
				}
			})[@windows]

			encodingScript = aegisub.decode_path "#{.pre}/a-mo.encode#{.ext}"
			encodingScriptFile = io.open encsh, "w+"
			windowAssert encodingScriptFile, "Encoding script could not be written. Something is wrong with your temp dir."
			sh\write global.enccom\gsub( "#(%b{})", (token) -> tokens[token\sub(2, -2)] ) .. .postExec
			sh\close!
			.execFunc .exec\format encsh
