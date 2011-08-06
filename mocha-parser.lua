script_name = "MOPE"
script_description = "Mocha Output Parser EXTREME"
script_author = ""
script_version = "0.0.1"
include("karaskel.lua")
gui = {}

gui.main = {
	{ 
		class = "label";
			x = 0; y = 0; height = 1; width = 10;
		label = "Please enter a path to the mocha output. Can only take one file."
	},
	{
		class = "label";
			x = 0; y = 2; height = 1; width = 1;
		label = "File Path:"
	},
	{
		class = "textbox";
			x = 1; y = 1; height = 4; width = 7;
		name = "mocpat"; hint = "Full path to file. No quotes or escapism needed."
	}
}
gui.options = {} -- add checkboxes for each parameter: xpos, ypos, xscl, yscl, zrot (and/or support for shearing/perspective)

function init_input(sub, sel, act)
	local config
	local opts = 0
	local button = {"Let's go", "Never mind"}
	aegisub.progress.title("Mincing Gerbils")
	button, config = aegisub.dialog.display(gui.main, button)
	if button == "Let's go" then
		frame_by_frame(sub,sel,opts,config.mocpat)
		aegisub.set_undo_point("Apply motion data") -- this doesn't seem to actually do anything
	else
		aegisub.progress.task("Cancelled")
	end
end

function string:split(sep) -- borrowing a split function from the lua-users wiki
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end

function parse_input(infile)
	local ftab = {}
	local xpos, ypos, xscl, yscl, zrot = {}, {}, {}, {}, {}
	local sect, care = 0, 0
	mocha = {}
	for line in io.lines(infile) do
		table.insert(ftab,line) -- dump the lines from the file into a table, elegantly named filetable or ftab for short
	end
	for keys, valu in pairs(ftab) do -- some really ugly parsing code yo
		val = valu:split("\t")
		if val[1] == "Anchor Point" or val[1] == "Position" or val[1] == "Scale" or val[1] == "Rotation" or val[1] == "End of Keyframe Data" then
			sect = sect + 1
			care = 0
		elseif val[1] == nil then
			care = 0
		else
			care = 1
		end
		if care == 1 and sect == 1 then
			if val[2] ~= "X pixels" then
				table.insert(xpos,tonumber(val[2]))
				table.insert(ypos,tonumber(val[3]))
			end
		elseif care == 1 and sect == 3 then
			if val[2] ~= "X percent" then
				table.insert(xscl,tonumber(val[2]))
				table.insert(yscl,tonumber(val[3]))
			end
		elseif care == 1 and sect == 4 then
			if val[2] ~= "Degrees" then
				table.insert(zrot,tonumber(val[2]))
			end
		end
	end
	flength = #xpos
	if flength == #ypos and flength == #xscl and flength == #yscl and flength == #zrot then -- make sure all of the elements are the same length.
		mocha.xpos = xpos
		mocha.ypos = ypos
		mocha.xscl = xscl
		mocha.yscl = yscl
		mocha.zrot = zrot
		return mocha -- return a table because it's prettier that way
	else
		--return some system crippling error and wonder how the hell mocha's output is messed up
		aegisub.log(0,"Somehow, the mocha input is wrong. ABORT ABORT")
	end
end

function frame_by_frame(sub,sel,opts,mochain) -- for some reason, active_line always returns -1 for me.
	local meta, styles = karaskel.collect_head(sub,false) -- get the style information
	mline = {} -- intializing variables
	mline.line = {} -- get the start frame of the selected line
	mline.endframe = aegisub.frame_from_ms(sub[sel[1]].end_time)
	mline.startframe = aegisub.frame_from_ms(sub[sel[1]].start_time)
	mline.numframes = mline.endframe-mline.startframe -- karaskel grabs an extra frame on the end
	for i, v in pairs(sel) do -- safe to assume all of the lines are the same length. They damn well better be.
		mline.line[i] = sub[v]
		mline.line[i].comment = true
		sub[v] = mline.line[i] -- comment out the original lines
		mline.line[i].comment = false
	end
	mocha = parse_input(mochain)
	for i,v in pairs(mline.line) do
		for x = 1,mline.numframes do
			spline = mline.line[i]
			spline.start_time = aegisub.ms_from_frame(mline.startframe+x-1)
			spline.end_time = aegisub.ms_from_frame(mline.startframe+x)
			spline.text = pos_and_scale(mline.line[i],spline,mocha,styles,x)
			sub.insert(sel[1]+x,spline) -- requires input in a table format which already makes things easier
		end
	end
end

function pos_and_scale(orgline,curfline,mocha,styles,i)
	newtxt = string.gsub(curfline.text,"\\pos%(([0-9]+%.?[0-9]*),([0-9]+%.?[0-9]*)%)",string.format("\\pos(%g,%g)",round(mocha.xpos[i],2),round(mocha.ypos[i],2)))
	return newtxt
end
	
function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

--[[function make_gui(x)
	local tab = {}
	for i, v in ipairs(x) do
		subta = { 
			class = "label";
				x = 0; y = i-1; height = 1; width = 10;
			label = x[i]
		}
		table.insert(tab,subta)
	end
	return tab
end]]

function isvideo() -- a very rudimentary (but hopefully efficient) check to see if there is a video loaded.
	if aegisub.video_size() then
		return true
	else
		return false
	end
end

aegisub.register_macro("Mocha Parser","MOPE", init_input, isvideo)