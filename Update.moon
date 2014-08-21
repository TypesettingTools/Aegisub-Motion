log = require 'a-mo.Log'

class Update
	new: =>
		log.debug tostring _G.script_upstream
