function header(sub)
	local vid
	for i,k in pairs(aegisub) do
		aegisub.log(0,'%s\n',i)
	end
	for x = 1,#sub do
		local line = sub[x]
		if line.class == "info" then
			if sub[x].key == "Video File" then
				vid = 1
				aegisub.log(0,"-> %s: %s\n",tostring(line.key),tostring(line.value))
			else
				-- aegisub.log(0,"%s: %s\n",tostring(line.key),tostring(line.value))
			end
		end
	end
	if not vid then
		aegisub.log(0,"No 'Video File' header found.\n")
	end
end

aegisub.register_macro("header","header", header)