ffi = require "ffi"
log = require "a-mo.Log"

windows = ffi.os == "Windows"

class TrimHandler

	windows: windows

	existingPresets: {
		"x264", "ffmpeg"
	}

	-- Set up encoder presets.
	defaults: {
		x264:    '"#{encbin}" --crf 16 --tune fastdecode -i 250 --fps 23.976 --sar 1:1 --index "#{prefix}/#{index}.index" --seek #{startf} --frames #{lenf} -o "#{prefix}/#{output}[#{startf}-#{endf}].mp4" "#{inpath}/#{input}"'
		ffmpeg:  '"#{encbin}" -ss #{startt} -sn -i "#{inpath}/#{input}" -vframes #{lenf} "#{prefix}/#{output}[#{startf}-#{endf}]-%05d.jpg"'
		-- avs2pipe: 'echo FFVideoSource("#{inpath}#{input}",cachefile="#{prefix}#{index}.index").trim(#{startf},#{endf}).ConvertToRGB.ImageWriter("#{prefix}/#{output}-[#{startf}-#{endf}]\\",type="png").ConvertToYV12 > "#{temp}/a-mo.encode.avs"\nmkdir "#{prefix}#{output}-[#{startf}-#{endf}]"\n"#{encbin}" video "#{temp}/a-mo.encode.avs"\ndel "#{temp}/a-mo.encode.avs"'
		-- vapoursynth:
	}

	-- Example trimConfig:
	-- trimConfig = {
	-- 	-- The prefix is the directory the output will be written to. It
	-- 	-- is passed through aegisub.decode_path.
	-- 	prefix: "?video"

	-- 	-- The name of the built in encoding preset to use. Overridden by
	-- 	-- command if that is neither nil nor an empty string.
	-- 	preset: "x264"

	-- 	-- The path of the executable used to actually do the encoding.
	-- 	-- Full path is recommended as the shell environment may be
	-- 	-- different than expected on non-windows systems.
	-- 	encBin: "C:\x264.exe"

	-- 	-- A custom encoding command that can be used to override the
	-- 	-- built-in defaults. Usable token documentation to come.
	-- 	-- Overrides preset if that is set.
	-- 	command: nil

	-- 	-- Script should attempt to create prefix directory.
	-- 	makePfix: nil
	-- }
	new: ( trimConfig ) =>
		@tokens = { }
		if trimConfig.command != nil and trimConfig.command != ""
			@command = trimConfig.command
		else
			@command = @defaults[trimConfig.preset]

		@makePrefix = trimConfig.makePfix

		with @tokens
			if windows
				.temp = os.getenv('TEMP')
			else
				.temp = "/tmp"
			.encbin = trimConfig.encBin
			.prefix = aegisub.decode_path trimConfig.prefix
			.inpath = aegisub.decode_path "?video"
			.log    = aegisub.decode_path "#{.temp}/a-mo.encode.log"

		getVideoName @

	getVideoName = =>
		with @tokens
			video = aegisub.project_properties!.video_file
			if video\len! == 0
				log.windowError "Aegisub thinks your video is 0 frames long.\nTheoretically it should be impossible to get this error."
			.input = video\sub .inpath\len! + 2
			.index = .input\match "(.+)%.[^%.]+$"
			.output = .index

	calculateTrimLength: ( lineCollection ) =>
		with @tokens
			.startt = lineCollection.startTime
			.endt   = lineCollection.endTime
			.lent   = .endt - .startt
			.startf = lineCollection.startFrame
			.endf   = lineCollection.endFrame - 1
			.lenf   = lineCollection.totalFrames

	performTrim: =>
		with platform = ({
				[true]:  {
					pre: @tokens.temp
					ext: ".bat"
					exec: '""%s""'
					preCom: @makePrefix and "mkdir \"#{@tokens.prefix}\"\n" or ""
					postCom: " > #{@tokens.log} 2>&1"
					execFunc: ( encodeScript ) ->
						success = os.execute encodeScript
						unless success
							logFile = io.open @tokens.log, 'r'
							encodeLog = logFile\read '*a'
							log.warn "\nEncoding error:"
							log.warn encodeLog
							log.windowError "Encoding failed. Log has been printed to progress window."
				}
				[false]: {
					pre: @tokens.temp
					ext: ".sh"
					exec: 'sh "%s"'
					preCom: @makePrefix and "mkdir -p \"#{@tokens.prefix}\"\n" or ""
					postCom: " 2>&1"
					execFunc: ( encodeScript ) ->
						logFile = io.popen encodeScript, 'r'
						encodeLog = logFile\read '*a'
						-- When closing a file handle created with io.popen,
						-- file:close returns the same values returned by
						-- os.execute.
						success = logFile\close!
						unless success
							log.warn "\nEncoding error:"
							log.warn encodeLog
							log.windowError "Encoding failed. Log has been printed to progress window."
				}
			})[windows]

			encodeScript = aegisub.decode_path "#{.pre}/a-mo.encode#{.ext}"
			encodeScriptFile = io.open encodeScript, "w+"
			unless encodeScriptFile
				log.windowError "Encoding script could not be written.\nSomething is wrong with your temp dir (#{.pre})."
			encodeString = .preCom .. @command\gsub( "#{(.-)}", ( token ) -> @tokens[token] ) .. .postCom
			log.debug encodeString
			encodeScriptFile\write encodeString
			encodeScriptFile\close!
			.execFunc .exec\format encodeScript
