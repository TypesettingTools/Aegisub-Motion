return {
	version: "1.0.0"

	round: ( num, idp ) ->
		mult = 10^(idp or 0)
		math.floor( num * mult + 0.5 ) / mult

	dCos: (a) ->
		math.cos math.rad a

	dSin: (a) ->
		math.sin math.rad a

	dAtan: (y, x) ->
		math.deg math.atan2 y, x

	uuid: ->
		('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx')\gsub "[xy]", ( char ) ->
			('%x')\format char=="x" and math.random( 0, 15 ) or math.random 8, 11
}
