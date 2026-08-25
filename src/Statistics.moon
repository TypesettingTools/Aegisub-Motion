local json, log
version = '0.1.3'

haveDepCtrl, DependencyControl = pcall require, 'l0.DependencyControl'

if haveDepCtrl
	version = DependencyControl {
		name: 'Statistics'
		:version
		description: 'A class for proving how cool you are.'
		author: 'torque'
		url: 'https://github.com/TypesettingTools/Aegisub-Motion'
		moduleName: 'a-mo.Statistics'
		feed: 'https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json'
		{
			{ 'json' }
			{ 'a-mo.Log',  version: '1.0.0' }
		}
	}
	json, log = version\requireModules!

else
	json = require 'json'
	log  = require 'a-mo.Log'

-- example = {
-- 	macroRunCount: {
-- 		Apply: 0
-- 		Trim: 0
-- 		Revert: 0
-- 	}
-- 	longestLine: 0
-- 	longestTrack: 0
-- 	largestOutput: 0
-- 	totalProduced: 0
-- 	uuid: 0
-- }

-- No way to migrate to different layouts. Seems like a pain in the ass.
-- Probably won't get implemented.
class Statistics
	@version: version

	new: ( @stats, fileName, filePath = aegisub.decode_path( '?user' ) ) =>
		@fileName = ('%s/%s')\format filePath, fileName
		@read!

	merge = ( memory, disk, seenTables ) ->
		unless seenTables[memory]
			seenTables[memory] = true
			for k, memVal in pairs memory
				if ("table" == type( disk )) and (nil != disk[k])
					diskVal = disk[k]
					if ("table" == type( diskVal )) and ("table" == type( memVal ))
						merge memVal, diskVal, seenTables
					else
						memory[k] = diskVal

	read: =>
		if fileHandle = io.open @fileName, 'r'
			success, serializedStats = pcall json.decode, fileHandle\read '*a'
			fileHandle\close!
			unless success
				log.warn "Couldn't parse stats from #{@filename} as valid json. This file will be overwritten."
				@write!
				return

			if serializedStats
				merge @stats, serializedStats, {}

		else
			@write!

	write: =>
		if fileHandle = io.open @fileName, 'w'
			serializedStats = json.encode @stats
			if serializedStats
				fileHandle\write serializedStats
			else
				log.debug "Couldn't serialize stats."
			fileHandle\close!
		else
			log.debug "Can't write statsfile: #{@fileName}"

	fullFieldNamePriv = false
	fieldBaseNamePriv = false
	fieldNamePriv     = false
	fieldPriv         = false

	pushFieldPriv = ( fieldName ) =>
		-- primary cache: nothing needs to change.
		if fullFieldNamePriv == fieldName
			return

		-- secondary cache: fieldPriv doesn't need to change, nor does
		-- fieldBaseNamePriv, but fullFieldNamePriv and fieldNamePriv do.
		tempFieldName = fieldName\gsub ".+%.", ""
		if fieldBaseNamePriv == fieldName\sub 0, -(#tempFieldName + 2)
			fullFieldNamePriv = fieldName
			fieldNamePriv = tempFieldName
			return

		-- Have to do everything from scratch.
		fieldPriv = @stats
		done = false
		fieldNamePriv = fieldName\gsub "([^%.]+)%.", ( subName ) ->
			if done
				return nil
			if "table" != type fieldPriv[subName]
				done = true
				return nil
			fieldPriv = fieldPriv[subName]
			return ""

		-- Bad things will occur if fieldNamePriv has a '.' in it.
		fullFieldNamePriv = fieldName
		fieldBaseNamePriv = fieldName\sub 0, -(#fieldNamePriv + 2)

	-- Accept syntax like 'macroRunCount.Apply' for fieldName.
	-- `valueCb` is a function with the signature ( currentValue )
	setValuePriv = ( fieldName, valueCb ) =>
		pushFieldPriv @, fieldName
		fieldPriv[fieldNamePriv] = valueCb fieldPriv[fieldNamePriv]

	incrementValue: ( fieldName, amount = 1 ) =>
		setValuePriv @, fieldName, ( value ) ->
			value + amount

	-- Convenience.
	decrementValue: ( fieldName, amount = 1 ) =>
		setValuePriv @, fieldName, ( value ) ->
			value - amount

	setValue: ( fieldName, newValue ) =>
		setValuePriv @, fieldName, ( value ) ->
			newValue

	setMax: ( fieldName, amount ) =>
		setValuePriv @, fieldName, ( value ) ->
			math.max value, amount

	setMin: ( fieldName, amount ) =>
		setValuePriv @, fieldName, ( value ) ->
			math.min value, amount

	getValue: ( fieldName ) =>
		pushFieldPriv @, fieldName
		return fieldPriv[fieldNamePriv]

if haveDepCtrl
	return version\register Statistics
else
	return Statistics
