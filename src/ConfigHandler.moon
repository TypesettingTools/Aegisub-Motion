json = require "json"
log = require "a-mo.Log"

class ConfigHandler

	-- The minimum required format for `optionTables` is
	-- { section: { optionname: { value: optionvalue, config: (true|false) } } }
	-- the config key exists because this is designed to be embedded in dialog
	-- tables. Some dialog elements may not be intended to be saved to a
	-- config file, or are labels that do not return a value.

	-- Constructor
	new: ( @optionTables, fileName, hasSections, @version = "0.0.1", filePath = "?user" ) =>
		@fileName = aegisub.decode_path "#{filePath}/#{fileName}"
		@fileHandle = nil
		loadDefault @

	-- Private methods (I probably shouldn't have bothered to do this!)
	loadDefault = =>
		@configuration = { }
		for sectionName, configEntries in pairs @optionTables
			@configuration[sectionName] = { }
			for optionName, configEntry in pairs configEntries
				if configEntry.config
					@configuration[sectionName][optionName] = configEntry.value

	parse = =>
		rawConfigText = @fileHandle\read '*a'
		-- Avoid clobbering the things loaded by loadDefault. I need to
		-- decide how I want to handle version changes between a script's
		-- built-in defaults and the serialized configuration on disk. This
		-- is currently biased towards a script's built-in defaults.
		parsedConfig = json.decode rawConfigText
		for sectionName, configEntries in pairs parsedConfig
			if configSection = @configuration[sectionName]
				for optionName, optionValue in pairs configEntries
					if configSection[optionName] != nil
						configSection[optionName] = optionValue

	-- Public methods
	read: =>
		if @fileHandle = io.open @fileName, 'r'
			parse @
			@fileHandle\close!
		else
			log.warn "Configuration file \"#{@fileName}\" can't be read. Writing defaults."
			@write!

	-- todo: find keys missing from either @conf or interface, and warn
	-- (maybe error?) about mismatching config versions.
	updateInterface: ( sectionNames ) =>
		if sectionNames
			if "table" == type sectionNames
				for sectionName in *sectionNames
					doInterfaceUpdate @, @optionTables[sectionName], sectionName
			else
				doInterfaceUpdate @, @optionTables[sectionNames], sectionNames

		else
			for sectionName, section in pairs @optionTables
				if @configuration[sectionName] != nil
					doInterfaceUpdate @, section, sectionName

	doInterfaceUpdate = ( section, sectionName ) =>
		for tableKey, tableValue in pairs section
			log.debug "#{tableKey}: #{tableValue}"
			if tableValue.config and @configuration[sectionName][tableKey] != nil
				tableValue.value = @configuration[sectionName][tableKey]

	-- maybe updateConfigurationFromDialog (but then we're getting into
	-- obj-c identifier verbosity territory, and I'd rather not go there)
	updateConfiguration: ( resultTable, sectionNames ) =>
		-- do nothing if sectionName isn't defined.
		if sectionName
			if "table" == type sectionNames
				for section in *sectionNames
					doConfigUpdate @, resultTable[section], section
			else
				doConfigUpdate @, resultTable, sectionNames
		else
			log.warn "Section Name not provided. You are doing it wrong."

	doConfigUpdate = ( newValues, sectionName ) =>
		-- have to loop across @configuration because not all of the
		-- fields in the result table are going to be serialized, and it
		-- contains no information about which ones should be and which
		-- ones should not be.
		for configKey, configValue in pairs @configuration[sectionName]
			if newValues[configKey] != nil
				@configuration[sectionName][configKey] = newValues[configKey]

	write: =>
		-- Make sure @configuration is not an empty table.
		unless next( @configuration ) == nil
			@configuration.__version = @version
			serializedConfig = json.encode @configuration
			@configuration.__version = nil
			log.debug serializedConfig
			if @fileHandle = io.open @fileName, 'w'
				@fileHandle\write serializedConfig
				@fileHandle\close!
			else
				log.warn "Could not write \"#{@fileName}\"."

return ConfigHandler
