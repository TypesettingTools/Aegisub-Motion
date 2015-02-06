log               = require 'a-mo.Log'
ShakeShapeHandler = require 'a-mo.ShakeShapeHandler'
DataHandler       = require 'a-mo.DataHandler'
bit               = require 'bit'

class DataWrapper
	@version: 0x010001
	@version_major: bit.rshift( @version, 16 )
	@version_minor: bit.band( bit.rshift( @version, 8 ), 0xFF )
	@version_patch: bit.band( @version, 0xFF )
	@version_string: ("%d.%d.%d")\format @version_major, @version_minor, @version_patch

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
