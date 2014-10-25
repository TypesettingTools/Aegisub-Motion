log               = require 'a-mo.Log'
ShakeShapeHandler = require 'a-mo.ShakeShapeHandler'
DataHandler       = require 'a-mo.DataHandler'

class DataWrapper
	new: =>

	tryDataHandler = ( input ) =>
		@dataObject = DataHandler input, @scriptResX, @scriptResY
		if @dataObject.length
			@type = "TSR"
			return true

		return false

	tryShakeShape = ( input ) =>
		@dataObject = ShakeShapeHandler input
		if @dataObject.length
			@type = "SRS"
			return true

		return false

	bestEffortParsingAttempt: ( input, scriptResX, scriptResY ) =>
		@scriptResX, @scriptResY = tonumber( scriptResX ), tonumber( scriptResY )
		log.dump {@scriptResX, @scriptResY}
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
