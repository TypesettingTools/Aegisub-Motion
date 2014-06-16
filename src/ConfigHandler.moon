json = require "json"

class ConfigHandler
	-- The minimum required format for `optionTables` is
	-- { optionname: { value: optionvalue, config: (true|false) } }
	-- the config key exists because this is designed to be embedded in dialog
	-- tables. Some dialog elements may not be intended to be saved to a
	-- config file, or are labels that do not return a value.
	new: ( optionTables, fileName = "aegisub-motion.conf" ) =>
		@fileName = aegisub.decode_path "?script/#{fileName}"
		@fileHandle = nil
		@configuration = {}

	loadDefault: =>
		for sectionName, configEntries in pairs optionTables
			@configuration[sectionName] = {}
			for optionTitle, configEntry in pairs configEntries
				if configEntry.config
					@configuration[sectionName][optionTitle] = configEntry.value

	read: =>
		if @fileHandle = io.open @fileName, 'r'
			@parse!
			@fileHandle\close!
		else
			debug "Configuration file \"#{@fileName}\" can't be read. Writing defaults."
			@loadDefault!
			@write!

	write: =>
		unless next( @configuration ) == nil
			json.encode @configuration

	parse: =>
		rawConfigText = @fileHandle\read '*a'
		@configuration = json.decode rawConfigText
