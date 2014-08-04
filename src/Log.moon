return {
	debug: (...) ->
		aegisub.log 4, ...
		aegisub.log 4, '\n'

	warn: (...) ->
		aegisub.log 2, ...
		aegisub.log 2, '\n'

	-- I am not sure this is the logical place for this function.
	checkCancellation: ->
		if aegisub.progress.is_cancelled!
			aegisub.cancel!

	windowError: ( errorMessage ) ->
		aegisub.dialog.display { { class: "label", label: errorMessage } }, { "&Close" }, { cancel: "&Close" }
		aegusb.cancel!
}
