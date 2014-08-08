return {
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
			randomNumber = math.random 0, 15
			if char != 'x'
				randomNumber = math.random 8, 11
			('%x')\format randomNumber
}
