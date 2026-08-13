local log, DataHandler, ShakeShapeHandler
version = '1.0.2'

haveDepCtrl, DependencyControl = pcall require, 'l0.DependencyControl'

if haveDepCtrl
	version = DependencyControl {
		name: 'DataWrapper',
		:version,
		description: 'A class for wrapping motion data.',
		author: 'torque',
		url: 'https://github.com/TypesettingTools/Aegisub-Motion'
		moduleName: 'a-mo.DataWrapper'
		feed: 'https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json'
		{
			{ 'a-mo.Log',               version: '1.0.0'               }
			{ 'a-mo.DataHandler',       version: '1.0.5'       }
			{ 'a-mo.ShakeShapeHandler', version: '1.0.2' }
		}
	}
	log, DataHandler, ShakeShapeHandler = version\requireModules!
else
	log               = require 'a-mo.Log'
	DataHandler       = require 'a-mo.DataHandler'
	ShakeShapeHandler = require 'a-mo.ShakeShapeHandler'

class DataWrapper
	@version: version
	new: =>

	tryDataHandler = ( input ) =>
		@dataObject = DataHandler input, @scriptResX, @scriptResY
		if @dataObject.length
			@type = "TSR"
			return true

		return false

	tryShakeShape = ( input ) =>
		@dataObject = ShakeShapeHandler input, @scriptResY
		if @dataObject.length
			@type = "SRS"
			return true

		return false

	bestEffortParsingAttempt: ( input, scriptResX, scriptResY ) =>
		if "string" != type( input )
			return false

		@scriptResX, @scriptResY = tonumber( scriptResX ), tonumber( scriptResY )
		if input\match '^Adobe After Effects 6.0 Keyframe Data'
			if tryDataHandler @, input
				return true

		elseif input\match '^shake_shape_data 4.0'
			if tryShakeShape @, input
				return true

		else
			if tryDataHandler @, input
				return true

			if tryShakeShape @, input
				return true

		return false

if haveDepCtrl
	return version\register DataWrapper
else
	return DataWrapper
