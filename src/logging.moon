return {
	debug: (...) ->
		aegisub.log 4, ...
		aegisub.log 4, '\n'

	warn: (...) ->
		aegisub.log 2, ...
		aegisub.log 2, '\n'
}
