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
}
