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
  5. For fear of someone else attempting to steal my INTELLECTUAL PROPERTY, which
    is the result of MY OWN PERSONAL EFFORT and has come at the consequence of the
    EVAPORATION of ALL OF MY FREE TIME, I have decided to make ARBITRARY PARTS of
    this script PROPRIETARY CODE that THE USER IS ABSOLUTELY AND EXPLICITLY VERBOTEN
    FROM LOOKING AT AT ANY TIME.
  6. This LICENSE AGREEMENT, which is IMPLICITLY AGREED TO upon usage of the script,
    regardless of whether or not THE USER has actually read it, IS RETROACTIVELY
    EXTENSIBLE. This means that ANY SUBSEQUENT TERMS ADDED TO IT IMMEDIATELY APPLY
    TO ALL OF THE USER'S ACTIONS IN THE PAST, and THE USER should be VERY CAREFUL that
    they have not previously VIOLATED any FUTURE TERMS AND CONDITIONS lest they be
    legally OPPRESSED by ME in a COURT OF LAW.
--]]

script_name = "Aegisub-Motion"
script_description = "Adobe After Effects 6.0 keyframe data parser for Aegisub" -- also it suffers from memory leaks
script_author = "torque"
script_version = "010011101" -- no, I have no idea how this versioning system works either.
include("karaskel.lua")
include("utils.lua") -- because it saves me like 5 lines of code this way
gui = {}

gui.main = {
  { class = "textbox"; -- 1 - because it is best if it starts out highlighted.
      x =0; y = 1; height = 4; width = 10;
    name = "mocpat"; hint = "Full path to file. No quotes or escapism needed."},
  { class = "textbox";
      x = 0; y = 18; height = 4; width = 10;
    name = "preerr"; hint = "Any lines that didn't pass the prerun checks are noted here."},
  { class = "textbox";
      x = 0; y = 13; height = 4; width = 10;
    name = "mocper"; hint = "YOUR FRIENDLY NEIGHBORHOOD MATH.RANDOM() AT WORK"},
  { class = "label";
      x = 0; y = 12; height = 1; width = 10;
    label = "                                                      MOTD"}, --"  Enter the file to the path containing your shear/perspective data."},
  { class = "label";
      x = 0; y = 0; height = 1; width = 10;
    label = " Either give the filepath to the motion data, or paste it in its entirety."},
  { class = "label";
      x = 0; y = 6; height = 1; width = 10;
    label = "What tracking data should be applied?              Rounding"}, -- allows more accurate positioning >_>
  { class = "label";
      x = 0; y = 7; height = 1; width = 1;
    label = "Position:"},
  { class = "checkbox";
      x = 1; y = 7; height = 1; width = 1;
    value = true; name = "pos"},
  { class = "label";
      x = 0; y = 8; height = 1; width = 1;
    label = "Scale:"},
  { class = "checkbox";
      x = 1; y = 8; height = 1; width = 1;
    value = true; name = "scl"},
  { class = "label";
      x = 0; y = 9; height = 1; width = 1;
    label = "Rotation:"},
  { class = "checkbox";
      x = 1; y = 9; height = 1; width = 1;
    value = false; name = "rot"},
  { class = "intedit"; -- these are both retardedly wide and retardedly tall. They are downright frustrating to position in the interface.
      x = 7; y = 7; height = 1; width = 3;
    value = 2; name = "pround"; min = 0; max = 5;},
  { class = "intedit";
      x = 7; y = 8; height = 1; width = 3;
    value = 2; name = "sround"; min = 0; max = 5;},
  { class = "intedit";
      x = 7; y = 9; height = 1; width = 3;
    value = 2; name = "rround"; min = 0; max = 5;},
  { class = "label";
      x = 2; y = 8; height = 1; width = 1;
    label = "Border:"},
  { class = "checkbox";
      x = 3; y = 8; height = 1; width = 1;
    value = true; name = "bord"},
  { class = "label";
      x = 4; y = 8; height = 1; width = 1;
    label = "Shadow:"},
  { class = "checkbox";
      x = 5; y = 8; height = 1; width = 1;
    value = true; name = "shad"},
  { class = "label";
      x = 0; y = 10; height = 1; width = 5;
    label = "Transforms (experimental):"},
  { class = "checkbox";
      x = 5; y = 10; height = 1; width = 1;
    value = true; name = "trans"},
  { class = "label";
      x = 0; y = 11; height = 1; width = 3;
    label = "VSfilter Compatibility:"},
  { class = "checkbox";
      x = 3; y = 11; height = 1; width = 1;
    value = false; name = "vsfilter"},
  { class = "label";
      x = 9; y = 11; height = 1; width = 2;
    label = ":esreveR"},
  { class = "checkbox";
      x = 8; y = 11; height = 1; width = 1;
    value = false; name = "reverse"}
}

gui.motd = { -- pointless because math.random doesn't work properly - BUT WHAT ABOUT OS.EXECUTE
  "The culprit was a huge truck.";
  "Error 0x0045AF: Runtime requested to be terminated in an unusual fashion.";
  "Powered by 100% genuine sweatshop child laborers.";
  "I hate you."
}

gui.halp = {
  { class = "label";
      x = 0; y = 0; height = 1; width = 1;
    label = "This help is really not as helpful as you want it to be. Sorry."}
}

function prerun_czechs(sub, sel, act) -- for some reason, act always returns -1 for me.
  local strt
  for x = 1,#sub do -- so if there are like 10000 different styles then this is probably a really bad idea but I DON'T GIVE A FUCK
    if sub[x].class == "dialogue" then -- BECAUSE I SAID SO
      strt = x-1 -- start line of dialogue subs
      break
    end
  end
  aegisub.progress.title("Preparing Gerbils")
  local accd = {}
  local _ = nil
  accd.meta, accd.styles = karaskel.collect_head(sub, false) -- dump everything I need later into the table so I don't have to pass o9k variables to the other functions
  accd.lines = {}
  accd.endframe = aegisub.frame_from_ms(sub[sel[1]].end_time) -- get the end frame of the first selected line
  accd.startframe = aegisub.frame_from_ms(sub[sel[1]].start_time) -- get the start frame of the first selected line
  accd.poserrs, accd.alignerrs = {}, {}
  accd.errmsg = ""
  local numlines = #sel
  for i, v in pairs(sel) do -- burning cpu cycles like they were no thing
    local opline = table.copy(sub[v]) -- I have no idea if a shallow copy is even an intelligent thing to do here
    opline.xscl, opline.yscl, opline.zrot, opline.trans = {}, {}, {}, {}
    opline.bord, opline.xbord, opline.ybord = {}, {}, {}
    opline.shad, opline.xshad, opline.yshad = {}, {}, {}
    opline.num = v -- this is for, uh, later.
    local _,fx,fy,ali,t_start,t_end,t_exp,t_eff,frz,xbord,ybord,xshad,yshad,resetti = nil
    karaskel.preproc_line(sub, accd.meta, accd.styles, opline) -- get that extra position data
    aegisub.log(5,"Line %d's style name is: %s\n",v-strt,opline.style) -- lines with more than one style can suck a dick (see: \r[stylename])
    opline.xscl = accd.styles[opline.style].scale_x
    aegisub.log(5,"Line %d's style's xscale is: %g\n",v-strt,opline.xscl)
    opline.yscl = accd.styles[opline.style].scale_y
    aegisub.log(5,"Line %d's style's yscale is: %g\n",v-strt,opline.yscl)
    opline.ali = accd.styles[opline.style].align
    aegisub.log(5,"Line %d's style's alignment is: %d\n",v-strt,opline.ali)
    opline.zrot = accd.styles[opline.style].angle
    aegisub.log(5,"Line %d's style's z-rotation is: %d\n",v-strt,opline.zrot)
    opline.xbord = accd.styles[opline.style].outline
    opline.ybord = accd.styles[opline.style].outline
    aegisub.log(5,"Line %d's style's border is: %d\n",v-strt,opline.xbord)
    opline.xshad = accd.styles[opline.style].shadow
    opline.yshad = accd.styles[opline.style].shadow
    aegisub.log(5,"Line %d's style's shadow is: %d\n",v-strt,opline.xshad)
    _,_,opline.xpos,opline.ypos = string.find(opline.text,"\\pos%(([%-%d%.]+),([%-%d%.]+)%)") -- always the first one
    _,_,opline.xorg,opline.yorg = string.find(opline.text,"\\org%(([%-%d%.]+),([%-%d%.]+)%)") -- idklol
    for a in string.gfind(opline.text,"%{(.-)%}") do -- this will find comment/override tags yo (on an unrelated note, the .- lazy repition is nice. It's shorter than .+? at least.)
      -- for b in string.gfind(a,"(\\[^\\]+)") do --find any thing between \ and \. Real comment lines should be separate from override tag blocks.
      aegisub.log(5,"Found a comment/override command in line %d: %s\n",v-strt,a)
      _,_,fx = string.find(a,"\\fscx([%d%.]+)")
      _,_,fy = string.find(a,"\\fscy([%d%.]+)")
      _,_,ali = string.find(a,"\\an([1-9])")
      _,_,frz = string.find(a,"\\frz?([%-%d%.]+)")
      _,_,bord = string.find(a,"\\bord([%d%.]+)")
      _,_,xbord = string.find(a,"\\xbord([%d%.]+)") 
      _,_,ybord = string.find(a,"\\ybord([%d%.]+)")
      _,_,shad = string.find(a,"\\shad([%-%d%.])")
      _,_,xshad = string.find(a,"\\xshad([%-%d%.]+)")
      _,_,yshad = string.find(a,"\\yshad([%-%d%.]+)")
      _,_,resetti = string.find(a,"\\r([^\\]+)") -- not sure I actually want to support this
      _,_,t_start,t_end,t_exp,t_eff = string.find(a,"\\t%(([%-%d]+),([%-%d]+),([%d%.]*),?([\\%.%-&%w%(%)]+)%)") -- this will return an empty string for t_exp if no exponential factor is specified
      if t_exp == "" then t_exp = 1 end -- set it to 1 because stuff and things
      if t_start then table.insert(opline.trans,{tonumber(t_start),tonumber(t_end),tonumber(t_exp),t_eff}); aegisub.log(5,"Line %d: \\t(%g,%g,%g,%s) found\n",v-strt,t_start,t_end,t_exp,t_eff) end
      if fx then table.insert(opline.xscl,tonumber(fx)); aegisub.log(5,"Line %d: \\fscx%g found\n",v-strt, fx) end
      if fy then table.insert(opline.yscl,tonumber(fy)); aegisub.log(5,"Line %d: \\fscy%g found\n",v-strt, fy) end
      if bord then table.insert(opline.bord,tonumber(bord)); aegisub.log(5,"Line %d: \\bord%g found\n",v-strt, bord) end
      if xbord then table.insert(opline.xbord,tonumber(xbord)); aegisub.log(5,"Line %d: \\xbord%g found\n",v-strt, xbord) end
      if ybord then table.insert(opline.ybord,tonumber(ybord)); aegisub.log(5,"Line %d: \\ybord%g found\n",v-strt, ybord) end
      if shad then table.insert(opline.bord,tonumber(shad)); aegisub.log(5,"Line %d: \\shad%g found\n",v-strt, shad) end
      if xshad then table.insert(opline.xbord,tonumber(xshad)); aegisub.log(5,"Line %d: \\xshad%g found\n",v-strt, xshad) end
      if yshad then table.insert(opline.ybord,tonumber(yshad)); aegisub.log(5,"Line %d: \\yshad%g found\n",v-strt, yshad) end
      if frz then table.insert(opline.zrot,tonumber(frz)); aegisub.log(5,"Line %d: \\frz%g found\n",v-strt, frz) end
      if ali then opline.ali = tonumber(ali); aegisub.log(5,"Line %d: \\an%d found\n",v-strt, ali) end -- the final \an is the one that's used.
    end
    if not opline.xpos then -- no way it would not find both trololo
      table.insert(accd.poserrs,{i,v})
      accd.errmsg = accd.errmsg..string.format("Line %d does not seem to have a position override tag.\n", v-strt)
    end
    --aegisub.log(5,"%d",opline.ali)
    if tonumber(opline.ali) ~= 5 then
      table.insert(accd.alignerrs,{i,v})
      accd.errmsg = accd.errmsg..string.format("Line %d does not seem aligned \\an5.\n", v-strt)
    end
    opline.startframe, opline.endframe = aegisub.frame_from_ms(opline.start_time), aegisub.frame_from_ms(opline.end_time)
    if opline.startframe < accd.startframe then -- make timings flexible. Number of frames total has to match the tracked data but
      aegisub.log(5,"Line %d: startframe changed from %d to %d\n",v-strt,accd.startframe,opline.startframe)
      accd.startframe = opline.startframe
    end
    if opline.endframe > accd.endframe then -- individual lines can be shorter than the whole scene
      aegisub.log(5,"Line %d: endframe changed from %d to %d\n",v-strt,accd.endframe,opline.endframe)
      accd.endframe = opline.endframe
    end
    if opline.endframe-opline.startframe>1 then
      table.insert(accd.lines,opline) -- SOLVED
    end
    opline.comment = true
    sub[v] = opline
    opline.comment = false -- because fuck you shallow copy.
  end
  local length = #accd.lines
  local copy = {}
  for i,v in ipairs(accd.lines) do
    copy[length-i+1] = v
  end
  accd.lines = copy -- this is probably going to do something horrible and fuck everything up because the table "copying" mechanics are ashdsiuhaslhasd
  length = nil
  copy = nil -- DOING MY OWN GARBAGE COLLECTION NOW LIKE A PRO (if this breaks something, I will cry)
  accd.lvidx, accd.lvidy = aegisub.video_size()
  accd.shx, accd.shy = accd.meta.res_x, accd.meta.res_y
  accd.totframes = accd.endframe - accd.startframe
  accd.toterrs = #accd.alignerrs + #accd.poserrs
  if accd.shx ~= accd.lvidx or accd.shy ~= accd.lvidy then -- check to see if header video resolution is same as loaded video resolution
    accd.errmsg = string.format("Header x/y res (%d,%d) does not match video (%d,%d).\n", accd.shx, accd.shy, accd.lvidx, accd.lvidy)..accd.errmsg
  end
  if accd.toterrs > 0 then
    accd.errmsg = "The lines noted below need to be checked.\n"..accd.errmsg
  else
    accd.errmsg = "None of the selected lines seem to be problematic.\n"..accd.errmsg 
  end
  assert(#accd.lines>0,"You have to select at least one line that is longer than one frame long.") -- pro error checking
  init_input(sub,accd)
end

function init_input(sub,accd) -- THIS IS PROPRIETARY CODE YOU CANNOT LOOK AT IT
  gui.main[2].text = accd.errmsg -- insert our error messages
  --os.execute("echo %RANDOM% > random.blargledarg") -- env var on windows (xp and newer)
  --os.execute("echo $RANDOM >> random.blargledarg") -- env var on various shells. Known to work: zsh and bash.
  --local _,_,rand = string.find(io.open("random.blargledarg",r):read("*a"),"([0-9]+)") -- tapdancing jesus h. christ, why is this such a retardedly roundabout way of doing this.
  -- the above does work, and has the added benefit of popping up and closing two terminal windows rapidly, which is very amusing. Possibly scare the shit out of someone who thinks their computzor has been haxxed. Actually, since lua doesn't seem to be sandboxed at all, you probably could hax someone's computer this way.
  local rand = ((os.clock()*os.time()+os.clock())*100) -- I suppose it's bad if this gives more variation than does math.random().
  gui.main[3].text = gui.motd[math.floor(rand%4)+1] -- this would work a lot better with more than 3 items
  local button, config = aegisub.dialog.display(gui.main, {"Go","Abort","Help"})
  if button == "Go" then
    if config.reverse then
      aegisub.progress.title("slibreG gnicniM") -- BECAUSE ITS FUNNY GEDDIT
    else
      aegisub.progress.title("Mincing Gerbils")
    end
    frame_by_frame(sub,accd,config)
  elseif button == "Help" then
    aegisub.progress.title("Helping Gerbils?")
    help(sub,accd)
  else
    aegisub.progress.task("ABORT")
  end
  aegisub.set_undo_point("Motion Data")
end

function help(su,ac)
  local button,config = aegisub.dialog.display(gui.halp,{"Close"})
  if button=="Close" then
    init_input(su,ac)
  end
end
  
function parse_input(input)
  local ftab = {}
  local sect, care = 0, 0
  local mocha = {}
  mocha.xpos, mocha.ypos, mocha.xscl, mocha.yscl, mocha.zrot = {}, {}, {}, {}, {}
  local datams = io.open(input,"r")
  if datams then
    for line in datams:lines() do
      line = string.gsub(line,"[\r\n]*","") -- FUCK YOU CRLF
      table.insert(ftab,line) -- dump the lines from the file into a table.
    end
    datams:close()
  else
    input = string.gsub(input,"[\r]*","") -- SERIOUSLY FUCK THIS SHIT
    ftab = input:split("\n")
  end
  for keys, valu in ipairs(ftab) do -- idk it might be more flexible now or something
    ---[[
    if valu == "Position" then
    sect = sect + 1
    elseif valu == "Scale" then
    sect = sect + 2
    elseif valu == "Rotation" then
    sect = sect + 4
    elseif valu == nil then
    sect = 0
    end
    if sect == 1 then
      if string.find(valu,"%d") then
        val = valu:split("\t")
        table.insert(mocha.xpos,tonumber(val[2]))
        table.insert(mocha.ypos,tonumber(val[3]))
      end
    elseif sect <= 3 and sect >= 2 then
      if string.find(valu,"%d") then
        val = valu:split("\t")
        table.insert(mocha.xscl,tonumber(val[2]))
        table.insert(mocha.yscl,tonumber(val[3]))
      end
    elseif sect <= 7 and sect >= 4 then
      if string.find(valu,"%d") then
        val = valu:split("\t")
        table.insert(mocha.zrot,-tonumber(val[2]))
      end
    end--]]
  end
  mocha.flength = #mocha.xpos
  assert(mocha.flength == #mocha.ypos and mocha.flength == #mocha.xscl and mocha.flength == #mocha.yscl and mocha.flength == #mocha.zrot,"The mocha data is not internally equal length.") -- make sure all of the elements are the same length (because I don't trust my own code).
  return mocha -- hurr durr
end

function frame_by_frame(sub,accd,opts)
  local mocha = parse_input(opts.mocpat) -- global variables have no automatic gc
  assert(accd.totframes==mocha.flength,"Number of frames from selected lines differs from number of frames tracked.")
  local _ = nil
  if not opts.scl then
    for k,d in ipairs(mocha.xscl) do
      d = 100
      mocha.yscl[k] = 100 -- so that yscl is changed too. 
    end
  end
  local operations = {} -- create a table and put the necessary functions into it, which will save a lot of if operations in the inner loop. This was the most elegant solution I came up with.
  --local eraser = {}
  if opts.pos then
    table.insert(operations,possify)
  end
  if opts.trans then
    table.insert(operations,transformate)
  end
  if opts.scl then
    if opts.vsfilter then
      table.insert(operations,VScalify)
    else
      table.insert(operations,scalify)
    end
    if opts.bord then
      table.insert(operations,bordicate)
    end
    if opts.shad then
      table.insert(operations,shadinate)
    end
  end
  if opts.vsfilter then
    opts.pround = 2 -- make it look better with libass?
    opts.sround = 2
    opts.rround = 2
  end
  if opts.rot then
    table.insert(operations,rotate)
  end
  for i,v in ipairs(accd.lines) do
    local rstartf = v.startframe - accd.startframe + 1 -- start frame of line relative to start frame of tracked data
    local rendf = v.endframe - accd.startframe -- end frame of line relative to start frame of tracked data
    if opts.reverse then
      rstartf, rendf = rendf, rstartf
    end
    if v.xorg and opts.rot then
      v.xorgd, v.yorgd = mocha.xpos[rstartf] - v.xorg, mocha.ypos[rstartf] - v.yorg -- not going to actually use this until I test it more.
    end
    if opts.rot then
      v.zrotd = mocha.zrot[rstartf] - v.zrot -- idr there was something silly about this
    end
    if v.xpos and opts.pos then
      v.xdiff, v.ydiff = mocha.xpos[rstartf] - v.xpos, mocha.ypos[rstartf] - v.ypos
    end
    --[[for ie, ei in ipairs(eraser) do
      v.text = string.gsub(v.text,ei,"")
    end--]]
    v.text = string.gsub(v.text,"{}","") -- Aesthetics, my friend. Aesthetics.
    local orgtext = v.text -- tables are passed as references.
    if opts.reverse then
      rstartf, rendf = rendf, rstartf
    end
    if opts.pos and not v.xpos then
      aegisub.log(1,"Line %d is being skipped because it is missing a \\pos() tag and you said to track position. Moron.",v.num) -- yeah that should do it.
    else
      if opts.reverse then -- donkey dongs
        for x = rstartf,rendf do
          local iter = rendf-x+1 -- hm
          v.ratx = mocha.xscl[iter]/mocha.xscl[rendf] -- DIVISION IS SLOW
          v.raty = mocha.yscl[iter]/mocha.yscl[rendf]
          v.start_time = aegisub.ms_from_frame(accd.startframe+iter-1)
          v.end_time = aegisub.ms_from_frame(accd.startframe+iter)
          v.time_delta = aegisub.ms_from_frame(accd.startframe+iter-1) - aegisub.ms_from_frame(accd.startframe)
          for vk,kv in ipairs(operations) do -- iterate through the necessary operations
            v.text = kv(v,mocha,opts,iter)
          end
          sub.insert(v.num+1,v)
          v.text = orgtext
        end
      else
        for x = rstartf,rendf do
          v.ratx = mocha.xscl[x]/mocha.xscl[rstartf] -- DIVISION IS SLOW
          v.raty = mocha.yscl[x]/mocha.yscl[rstartf]
          v.start_time = aegisub.ms_from_frame(accd.startframe+x-1)
          v.end_time = aegisub.ms_from_frame(accd.startframe+x)
          v.time_delta = aegisub.ms_from_frame(accd.startframe+x-1) - aegisub.ms_from_frame(accd.startframe)
          for vk,kv in ipairs(operations) do -- iterate through the necessary operations
            v.text = kv(v,mocha,opts,x)
          end
          v.text = string.gsub(v.text,string.char(1),"") -- clean those suckers up
          sub.insert(v.num+x-rstartf+1,v)
          v.text = orgtext
        end
      end
    end
  end
end

function possify(line,mocha,opts,iter)
  local xpos = mocha.xpos[iter]-(line.xdiff*line.ratx) -- allocating memory like a bawss
  local ypos = mocha.ypos[iter]-(line.ydiff*line.raty)
  return string.gsub(line.text,"\\pos%([%-%d%.]+,[%-%d%.]+%)","\\"..string.char(1)..string.format("pos(%g,%g)",round(xpos,opts.pround),round(ypos,opts.pround))) -- ☺
end

function transformate(line,mocha,opts,iter)
  for ix,vx in ipairs(line.trans) do
    local t_s = ix[1] - line.time_delta -- well, that was easy
    local t_e = ix[2] - line.time_delta
    string.gsub(ix,"\\t%([%-%d]+,[%-%d]+,[%d%.]*,?[\\%.%-&%w%(%)]+%)","\\"..string.char(1)..string.format("t(%i,%i,%g,%s)",t_s,t_e,ix[3],ix[4]),1) -- I hate how messy this expression is
  end
end

function scalify(line,mocha,opts)
  for ix,vx in ipairs(line.xscl) do
    string.gsub(line.text,"\\fscx[%d%.]+","\\"..string.char(1)..string.format("fscx%g)",round(vx*line.ratx,opts.sround)),1)
  end
  for ix,vx in ipairs(line.yscl) do
    string.gsub(line.text,"\\fscy[%d%.]+","\\"..string.char(1)..string.format("fscy%g)",round(vx*line.raty,opts.sround)),1)
  end
  return line.text
end

function bordicate(line,mocha,opts)
  for ix, vx in ipairs(line.bord) do
    string.gsub(line.text,"\\bord[%d%.]+","\\"..string.char(1)..string.format("bord%g)",round(vx*line.ratx,opts.sround)),1)
  end
  for ix, vx in ipairs(line.xbord) do
    string.gsub(line.text,"\\xbord[%d%.]+","\\"..string.char(1)..string.format("xbord%g)",round(vx*line.ratx,opts.sround)),1)
  end
  for ix, vx in ipairs(line.ybord) do
    string.gsub(line.text,"\\ybord[%d%.]+","\\"..string.char(1)..string.format("ybord%g)",round(vx*line.raty,opts.sround)),1)
  end
  return line.text
end

function shadinate(line,mocha,opts)
  for ix, vx in ipairs(line.shad) do
    string.gsub(line.text,"\\bord[%d%.]+","\\"..string.char(1)..string.format("shad%g)",round(vx*line.ratx,opts.sround)),1)
  end
  for ix, vx in ipairs(line.xshad) do
    string.gsub(line.text,"\\xbord[%d%.]+","\\"..string.char(1)..string.format("xshad%g)",round(vx*line.ratx,opts.sround)),1)
  end
  for ix, vx in ipairs(line.yshad) do
    string.gsub(line.text,"\\ybord[%d%.]+","\\"..string.char(1)..string.format("yshad%g)",round(vx*line.raty,opts.sround)),1)
  end
  return line.text
end

function VScalify(line,mocha,opts)
  for ix, vx in ipairs(line.xscl) do
    local xscl = round(line.xscl*line.ratx,2)
    local xlowend, xhighend, xdecimal = math.floor(xscl),math.ceil(xscl),xscl%1*100
    local xstart, xend = -xdecimal, 100-xdecimal
    string.gsub(line.text,"\\fscx[%d%.]+","\\"..string.char(1)..string.format("fscx%d\\t(%d,%d,\\"..string.char(1).."fscx%d)",xlowend,xstart,xend,xhighend),1)
  end
  for ix, vx in ipairs(line.yscl) do
    local yscl = round(line.yscl*line.raty,2)
    local ylowend, yhighend, ydecimal = math.floor(yscl),math.ceil(yscl),yscl%1*100
    local ystart, yend = -ydecimal, 100-ydecimal
    string.gsub(line.text,"\\fscy[%d%.]+","\\"..string.char(1)..string.format("fscy%d\\t(%d,%d,\\"..string.char(1).."fscy%d)",ylowend,ystart,yend,yhighend),1)
  end
  return line.text
end

function rotate(line,mocha,opts,iter)
  local orgx = mocha.xpos[iter]
  local orgy = mocha.ypos[iter] -- lol orgy
  string.gsub(line.text,"\\org%([%-%d%.]+,[%-%d%.]+%)","")
  string.gsub(line.text,"{",string.format("{\\org(%g,%g)",round(orgx,opts.rround),round(orgy,opts.rround)),1) -- INSERT
  for ix, vx in ipairs(line.zrot) do
    local frz = mocha.zrot[iter]-line.zrotd
    string.gsub(line.text,"\\frz?[%d%.]+",string.format("\\"..string.char(1).."frz%g",round(frz,opts.rround)),1)
  end
  return line.text
end

function round(num, idp) -- borrowed from the lua-users wiki (all of the intelligent code you see in here is)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function string:split(sep) -- borrowed from the lua-users wiki (single character split ONLY)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function isvideo() -- a very rudimentary (but hopefully efficient) check to see if there is a video loaded.
  return aegisub.video_size() and true or false -- (aegisub.video_size() and true) or false - if video_size() returns a value then the first part of the statement is true and therefore it returns true. Otherwise, it returns false.
end

aegisub.register_macro("Apply motion data","Applies properly formatted motion tracking data to selected subtitles.", prerun_czechs, isvideo)