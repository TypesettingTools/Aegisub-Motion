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

	dump: ( item ) ->
		if "table" != type item
			aegisub.log 4, tostring item
			aegisub.log 4, "\n"
			return

		count = 1
		tablecount = 1

		result = { "{ @#{tablecount}" }
		seen   = { [item]: tablecount }
		recurse = ( item, space ) ->
			for key, value in pairs item
				if "table" == type value
					unless seen[value]
						tablecount += 1
						seen[value] = tablecount
						count += 1
						result[count] = space .. "#{key}: { @#{tablecount}"
						recurse value, space .. "    "
						count += 1
						result[count] = space .. "}"
					else
						count += 1
						result[count] = space .. "#{key}: @#{seen[value]}"

				else
					if "string" == type value
						value = ("%q")\format value

					count += 1
					result[count] = space .. "#{key}: #{value}"

		recurse item, "    "

		count += 1
		result[count] = "}\n"
		aegisub.log 4, table.concat result, "\n"

	windowError: ( errorMessage ) ->
		aegisub.dialog.display { { class: "label", label: errorMessage } }, { "&Close" }, { cancel: "&Close" }
		aegisub.cancel!
}
