return {
	debug: (...) ->
		aegisub.log 4, ...
		aegisub.log 4, '\n'

	warn: (...) ->
		aegisub.log 2, ...
		aegisub.log 2, '\n'

	windowError: ( errorMessage ) ->
		aegisub.dialog.display { { class: "label", label: errorMessage } }, { "&Close" }, { cancel: "&Close" }
		aegusb.cancel!
}
