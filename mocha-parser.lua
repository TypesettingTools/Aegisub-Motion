--[[ 
I THOUGHT I SHOULD PROBABLY INCLUDE SOME LICENSING INFORMATION IN THIS
BUT I DON'T REALLY KNOW VERY MUCH ABOUT COPYRIGHT LAW AND IT ALSO SEEMS LIKE MOST
COPYRIGHT NOTICES JUST KIND OF YELL AT YOU IN ALL CAPS. AND APPARENTLY PUBLIC
DOMAIN DOES NOT EXIST IN ALL COUNTRIES, SO I FIGURED I'D STICK THIS HERE SO
YOU KNOW THAT YOU, HENCEFORTH REFERRED TO AS "THE USER" HAVE THE FOLLOWING
INALIABLE RIGHTS:

	0. THE USER can use this piece of poorly written code, henceforth referred to as
		THE SCRIPT, to do the things that it claims it can do.
	1. THE USER should not expect THE SCRIPT to do things that it does not expressly
		claim to be able to do, such as make coffee or print money.
	2. THE USER should realize that starting a list with 0 in a document that
		contains lua code is actually SOMEWHAT IRONIC.
	3. THE WRITER, henceforth referred to as I or ME, depending on the context, holds
		no responsibility for any problems that THE SCRIPT may cause, such as
		if it murders your dog.
	4. THE USER is expected to understand that this is just some garbage that I made
		up and that any and all LEGALLY BINDING AGREEMENTS THAT THE USER HAS AGREED
		TO UPON USAGE OF THE SCRIPT ARE UP TO THE USER TO DISCOVER ON HIS OR HER OWN,
		POSSIBLY THROUGH CLAIRVOYANCE OR MAYBE A SPIRITUAL MEDIUM.
--]]

script_name = "MOPE"
script_description = "Mocha Output Parser EXTREME"
script_author = "torque"
script_version = "0.0.1-2"
include("karaskel.lua")
gui = {}

gui.main = {
	{ -- 1
		class = "label";
			x = 0; y = 0; height = 1; width = 10;
		label = "Please enter a path to the mocha output. Can only take one file."
	},
	{ -- 2
		class = "textbox";
			x =0; y = 1; height = 4; width = 10;
		name = "mocpat"; hint = "Full path to file. No quotes or escapism needed.";
		text = "e.g.  C:\\path\\to the\\mocha.output"
	},
	{ -- 3
		class = "label";
			x = 0; y = 6; height = 1; width = 10;
		label = "What tracking data should be applied?"
	},
	{ -- 4
		class = "label";
			x = 0; y = 7; height = 1; width = 1;
		label = "Position:"
	},
	{ -- 5
		class = "checkbox";
			x = 1; y = 7; height = 1; width = 1;
		value = true; name = "pos"
	},
	{ -- 6
		class = "label";
			x = 2; y = 7; height = 1; width = 1;
		label = "Scale:"
	},
	{ -- 7
		class = "checkbox";
			x = 3; y = 7; height = 1; width = 1;
		value = true; name = "scl"
	},
	{ -- 8
		class = "label";
			x = 4; y = 7; height = 1; width = 1;
		label = "Rotation:"
	},
	{ -- 9
		class = "checkbox";
			x = 5; y = 7; height = 1; width = 1;
		value = false; name = "rot"
	},
	{ -- 10
		class = "label";
			x = 6; y = 7; height = 1; width = 1;
		label = "Shear:"
	},
	{ -- 11
		class = "checkbox";
			x = 7; y = 7; height = 1; width = 1;
		value = false; name = "shr"
	},
	{ -- 12
		class = "label";
			x = 8; y = 7; height = 1; width = 1;
		label = "Perspective:"
	},
	{ -- 13
		class = "checkbox";
			x = 9; y = 7; height = 1; width = 1;
		value = false; name = "per"
	},
	{  -- 14
		class = "label";
			x = 0; y = 9; height = 1; width = 10;
		label = "Enter the file to the path containing your shear/perspective data."
	},
	{ -- 15
		class = "textbox";
			x = 0; y = 10; height = 4; width = 10;
		name = "mocper"; hint = "Again, the full path to the file. No quotes or escapism needed.";
		text = "Rotation, shear and perspective are not supported yet. Filling in this box will currently do nothing."
	},
	{ -- 16
		class = "textbox";
			x = 0; y = 15; height = 4; width = 10;
		name = "preerr"; hint = "Any lines that didn't pass the prerun checks are noted here.";
	}
}

gui.halp = {
}

function prerun_czechs(sub, sel, act)
	aegisub.progress.title("Preparing Gerbils")
	local accd = {}
	accd.meta, accd.styles = karaskel.collect_head(sub,false) -- dump everything I need later into the table so I don't have to pass o9k variables to the other functions
	accd.lines = {}
	accd.endframe = aegisub.frame_from_ms(sub[sel[1]].end_time) -- get the end frame of the first selected line
	accd.startframe = aegisub.frame_from_ms(sub[sel[1]].start_time) -- get the start frame of the first selected line
	accd.alignerrs = {} -- initialize error count
	accd.poserrs = {}
	accd.errmsg = ""
	for i, v in pairs(sel) do -- burning cpu cycles like they were no thing
		local opline = table.copy(sub[v]) -- because I needed an excuse to use this function
		karaskel.preproc_line(sub, accd.meta, accd.styles, opline)
		_, _, opline.ali = string.find(opline.text,"\\an([1-9])") -- check for \an[1-9] override in line
		if not opline.ali then opline.ali = accd.styles[opline.style].align end -- if no override is found, replace with the style's alignment
		_,_,opline.posx, opline.posy = string.find(opline.text,"\\pos%((%-?[0-9]+%.?[0-9]*),(%-?[0-9]+%.?[0-9]*)%)")
		if not opline.posx then
			table.insert(accd.poserrs,{i,v})
			accd.errmsg = accd.errmsg..string.format("Line %d does not seem to have a position override tag.\n", v)
		end
		if opline.ali ~= 5 then -- check for \an5 alignment.
			table.insert(accd.alignerrs,{i,v})
			accd.errmsg = accd.errmsg..string.format("Line %d does not seem aligned \\an5.\n", v)..accd.errmsg
		end
		local opstart, opend = aegisub.frame_from_ms(opline.start_time), aegisub.frame_from_ms(opline.end_time)
		if opstart < accd.startframe then -- make timings flexible. Number of frames has to match
			accd.startframe = opstart
		end
		if opend > accd.endframe then
			accd.endframe = opend
		end
		opline.comment = true -- not sure if this is actually a good place to do the commenting or not.
		sub[v] = opline -- comment out the original line
		opline.comment = false
		table.insert(accd.lines,opline)
	end
	-- add check to see if header video resolution is same as loaded video resolution
	accd.lvidx, accd.lvidy = aegisub.video_size()
	accd.shx, accd.shy = accd.meta.res_x, accd.meta.res_y
	accd.toterrs = #accd.alignerrs + #accd.poserrs
	if accd.shx ~= accd.lvidx or accd.shy ~= accd.lvidy then 
		accd.errmsg = string.format("Header x/y res (%d,%d) does not match video (%d,%d).\n", accd.shx, accd.shy, accd.lvidx, accd.lvidy)..accd.errmsg
	end
	if accd.toterrs > 0 then
		accd.errmsg = "The lines noted below may need to be checked.\nThe issues will be forcibly fixed later depending\non what tracking data you choose to apply\n"..accd.errmsg
	else
		accd.errmsg = "WORD DOG F'RIZZLE NO ERRORS PEACE OUT"..accd.errmsg 
	end
	if #accd.lines == 0 then -- check to see if any of the lines were... selected? If none were, ERROR.
		error("SOMEHOW YOU HAVE SELECTED NO LINES WHATSOEVER. THIS IS AN IMPRESSIVE FEAT")
	end
	init_input(accd)
end

function ficks_pos(line)
	if line.ali == 1 then
		return line.center, line.vcenter
	elseif line.ali == 2 then

	elseif line.ali == 3 then

	elseif line.ali == 4 then

	elseif line.ali == 5 then

	elseif line.ali == 6 then

	elseif line.ali == 7 then

	elseif line.ali == 8 then

	elseif line.ali == 9 then

	else

	end
end

function init_input(lines)
	gui.main[16].text = lines.errmsg
	local config
	local opts = 0
	local button = {"Go", "Abort"}
	button, config = aegisub.dialog.display(gui.main, button)
	if button == "Go" then
		aegisub.progress.title("Mincing Gerbils")
		frame_by_frame(sub,sel,config)
		aegisub.set_undo_point("Apply motion data") -- this doesn't seem to actually do anything
	else
		aegisub.progress.task("ABORT")
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
				table.insert(xpos,tonumber(val[2])) -- is tonumber() actually necessary? Oh well.
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
		aegisub.log(0,"The mocha data is not internally equal length. Going into crash mode, t-10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0. Blast off.")
		error("YOU HAVE FUCKED EVERYTHING UP")
	end
end

function frame_by_frame(sub,sel,opts) -- for some reason, active_line always returns -1 for me.
--[[	meta, styles = karaskel.collect_head(sub,false) -- get the style information
	mline = {} -- intializing variables
	mline.line = {} -- have to declare this for the iterator function below to work]]
--	mline.endframe = aegisub.frame_from_ms(sub[sel[1]].end_time) -- get the start frame of the selected line
--	mline.startframe = aegisub.frame_from_ms(sub[sel[1]].start_time) -- get the end frame of the selected line
--	mline.numframes = mline.endframe-mline.startframe -- karaskel grabs an extra frame on the end
	--[[for i, v in pairs(sel) do -- safe to assume all of the lines are the same length. They damn well better be.
		if styles[sub[v].style] == 5 or string.find(sub[v].text,"\\an5") then -- check for \an5 alignment.
			table.insert(mline.line,sub[v])
			mline.line[#mline.line].comment = true
			sub[v] = mline.line[#mline.line] -- comment out the original line
			mline.line[#mline.line].comment = false
		else
			aegisub.log(2,"Line no. %d of the lines you selected was not aligned properly (no \\an5 found in the line or style) and is being ignored.\n", i)
		end
	end
	if #mline.line == 0 then --check to see if any of the lines passed the check. If none did, ragequit.
		error("I-It's not like a-any of your subtitle l-lines have the proper alignment, b-baka.")
	end]]
	mocha = parse_input(opts.mocpat)
	ecks = 1
	for i,v in pairs(mline.line) do
		xscl = {styles[v.style].scale_x, false} -- get scale information from the style
		yscl = {styles[v.style].scale_y, false}
		pa,pb,xpos,ypos = string.find(v.text,"\\pos%(([0-9]+%.?[0-9]*),([0-9]+%.?[0-9]*)%)") -- original x/ypos
		fxa,fxb,fxc = string.find(v.text,"\\fscx([0-9]+%.?[0-9]*)") -- look for override in the line itself
		fya,fyb,fyc = string.find(v.text,"\\fscy([0-9]+%.?[0-9]*)")
		if fxc then xscl = {fxc, true} end -- overwrite the scale if overrides are found
		if fyc then yscl = {fyc, true} end
		local diffx, diffy = mocha.xpos[1]-xpos, mocha.ypos[1]-ypos
		orgtext = v.text -- tables are passed as references.
		for x = 1,mline.numframes do
			v.start_time = aegisub.ms_from_frame(mline.startframe+x-1)
			v.end_time = aegisub.ms_from_frame(mline.startframe+x)
			v.text = pos_and_scale(v,mocha,xpos,ypos,diffx,diffy,xscl,yscl,x,opts) -- I AM NOT PASSING ENOUGH PARAMETERS
			sub.insert(sel[1]+ecks+i,v) -- requires input in a table format.
			ecks = ecks + 1
			v.text = orgtext
		end
	end
end

function pos_and_scale(curfline,mocha,oxpos,oypos,diffx,diffy,xscl,yscl,i,opt)
	if opt.scl and opt.pos then
		local xsclf = mocha.xscl[i]*xscl[1]/100
		local xpos = mocha.xpos[i]-(diffx*mocha.xscl[i]/100)
		local ysclf = mocha.yscl[i]*yscl[1]/100
		local ypos = mocha.ypos[i]-(diffy*mocha.yscl[i]/100)
		if xscl[2] and yscl[2] then -- check for override tags
			newtxt = string.gsub(curfline.text,"\\fscx([0-9]+%.?[0-9]*)",string.format("\\fscx%g",round(xsclf,2)),1) -- allow custom rounding?
			newtxt = string.gsub(newtxt,"\\fscy([0-9]+%.?[0-9]*)",string.format("\\fscy%g",round(ysclf,2)),1)
			newtxt = string.gsub(newtxt,"\\pos%(([0-9]+%.?[0-9]*),([0-9]+%.?[0-9]*)%)",string.format("\\pos(%g,%g)",round(xpos,2),round(ypos,2)),1)
		elseif xscl[2] then
			newtxt = string.gsub(curfline.text,"\\fscx([0-9]+%.?[0-9]*)",string.format("\\fscx%g",round(xsclf,2)),1)
			newtxt = string.gsub(newtxt,"\\pos%(([0-9]+%.?[0-9]*),([0-9]+%.?[0-9]*)%)",string.format("\\pos(%g,%g)\\fscy%g",round(xpos,2),round(ypos,2),round(ysclf,2)),1)
		elseif yscl[2] then
			newtxt = string.gsub(curfline.text,"\\fscx([0-9]+%.?[0-9]*)",string.format("\\fscy%g",round(ysclf,2)),1)
			newtxt = string.gsub(newtxt,"\\pos%(([0-9]+%.?[0-9]*),([0-9]+%.?[0-9]*)%)",string.format("\\pos(%g,%g)\\fscx%g",round(xpos,2),round(ypos,2),round(xsclf,2)),1)
		else
			newtxt = string.gsub(curfline.text,"\\pos%(([0-9]+%.?[0-9]*),([0-9]+%.?[0-9]*)%)",string.format("\\pos(%g,%g)\\fscx%g\\fscy%g",round(xpos,2),round(ypos,2),round(xsclf,2),round(ysclf,2)),1)
		end
		return newtxt
	elseif opt.pos then
		xpos = mocha.xpos[i]-diffx
		ypos = mocha.ypos[i]-diffy
		newtxt = string.gsub(curfline.text,"\\pos%(([0-9]+%.?[0-9]*),([0-9]+%.?[0-9]*)%)",string.format("\\pos(%g,%g)",round(xpos,2),round(ypos,2)))
	elseif opt.scl then
		newtxt = curfline.text -- because I am far too lazy to try to deal with a situation where you would have a scale change and not a position change
	end
	return newtxt
end
	
function round(num, idp) -- also borrowed for the lua-users wiki
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function table.copy(t) -- exactly what it says on the tin.
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function isvideo() -- a very rudimentary (but hopefully efficient) check to see if there is a video loaded.
	if aegisub.video_size() then return true else return false end
end

aegisub.register_macro("Mocha Parser","Mocha Output Parser Extreme", prerun_czechs, isvideo)