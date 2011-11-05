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
script_description = "Adobe After Effects 6.0 keyframe data parser for Aegisub" -- also it suffers from memory leaks?
script_author = "torque"
script_version = "0.0x00DEAF" -- no, I have no idea how this versioning system works either.
include("karaskel.lua")
include("utils.lua") -- because it saves me like 5 lines of code this way
gui = {}

gui.main = {
  { class = "textbox"; -- 1 - because it is best if it starts out highlighted.
      x =0; y = 1; height = 4; width = 10;
    name = "mocpat"; hint = "Full path to file. No quotes or escapism needed.";
    text = "e.g.  C:\\path\\to the\\mocha.output"},
  { class = "textbox";
      x = 0; y = 17; height = 4; width = 10;
    name = "preerr"; hint = "Any lines that didn't pass the prerun checks are noted here."},
  { class = "textbox";
      x = 0; y = 12; height = 4; width = 10;
    name = "mocper"; hint = "YOUR FRIENDLY NEIGHBORHOOD MATH.RANDOM() AT WORK"},
  { class = "label";
      x = 0; y = 0; height = 1; width = 10;
    label = "  Please enter the filepath to the motion data. Can only take one file."},
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
    value = true; name = "rot"},
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
      x = 0; y = 11; height = 1; width = 10;
    label = "                                                      MOTD"}, --"  Enter the file to the path containing your shear/perspective data."},
  { class = "label";
      x = 0; y = 10; height = 1; width = 3;
    label = "VSfilter Compatibility:"},
  { class = "checkbox";
      x = 3; y = 10; height = 1; width = 1;
    value = false; name = "vsfilter"},
  { class = "label";
      x = 9; y = 10; height = 1; width = 2;
    label = ":esreveR"},
  { class = "checkbox";
      x = 8; y = 10; height = 1; width = 1;
    value = false; name = "reverse"}
}

gui.motd = { -- pointless because math.random doesn't work properly
  "The culprit was a huge truck.";
  "Error 0x0045AF: Runtime requested to be terminated in an unusual fashion.";
  "Powered by 100% genuine sweatshop child laborers."
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
    opline.poserrs, opline.alignerrs = {}, {}
    opline.num = v -- this is for, uh, later.
    local _,fx,fy,ali,t_start,t_end,t_exp,t_eff,frz,xbord,ybord,xshad,yshad = nil
    karaskel.preproc_line(sub, accd.meta, accd.styles, opline) -- get that extra position data
    aegisub.log(5,"Line %d's style name is: %s\n",v-strt,opline.style)
    opline.xscl = accd.styles[opline.style].scale_x
    aegisub.log(5,"Line %d's style's xscale is: %g\n",v-strt,opline.xscl)
    opline.yscl = accd.styles[opline.style].scale_y
    aegisub.log(5,"Line %d's style's yscale is: %g\n",v-strt,opline.yscl)
    opline.ali = {accd.styles[opline.style].align, false} -- durf
    aegisub.log(5,"Line %d's style's alignment is: %d\n",v-strt,opline.ali[1])
    opline.zrot = accd.styles[opline.style].angle
    aegisub.log(5,"Line %d's style's z-rotation is: %d\n",v-strt,opline.zrot)
    opline.xbord = accd.styles[opline.style].outline
    opline.ybord = accd.styles[opline.style].outline
    aegisub.log(5,"Line %d's style's border is: %d\n",v-strt,opline.xbord)
    opline.xshad = accd.styles[opline.style].shadow
    opline.yshad = accd.styles[opline.style].shadow
    aegisub.log(5,"Line %d's style's shadow is: %d\n",v-strt,opline.xshad)
    for a in string.gfind(opline.text,"%{(.-)%}") do --- this will find comment/override tags yo
      aegisub.log(5,"Found a comment/override command in line %d: %s\n",v-strt,a)
    end
    _,_,fx = string.find(opline.text,"\\fscx([%d%.]+)")
    _,_,fy = string.find(opline.text,"\\fscy([%d%.]+)")
    for a in string.gfind(opline.text,"\\an([1-9])") do -- the last \an is the one that is used
      ali = a
    end
    _,_,frz = string.find(opline.text,"\\frz([%-%d%.]+)")
    _,_,bord = string.find(opline.text,"\\bord([%d%.]+)")
    _,_,shad = string.find(opline.text,"\\shad([%-%d%.])")
    _,_,t_start,t_end,t_exp,t_eff = string.find(opline.text,"\\t%(([%-%d]+),?([%-%d]+),?([%d%.]*),?([\\%.%-&%w]+)%)") -- this will return an empty string if no exponential factor is specified
    if t_exp == "" then t_exp = 1 end -- set it to 1 because stuff and things
    _,_,opline.xpos,opline.ypos = string.find(opline.text,"\\pos%(([%-%d%.]+),([%-%d%.]+)%)") -- The first \pos is the one that is used
    _,_,opline.xorg,opline.yorg = string.find(opline.text,"\\org%(([%-%d%.]+),([%-%d%.]+)%)") -- idklol
    if fx then opline.xscl = tonumber(fx); aegisub.log(5,"Line %d: \\fscx%g found\n",v-strt, fx) end
    if fy then opline.yscl = tonumber(fy); aegisub.log(5,"Line %d: \\fscy%g found\n",v-strt, fy) end
    if ali then opline.ali = {tonumber(ali), true}; aegisub.log(5,"Line %d: \\an%d found\n",v-strt, ali) end -- really do need this...?
    if frz then opline.zrot = tonumber(frz); aegisub.log(5,"Line %d: \\frz%g found\n",v-strt, frz) end
    if bord then
      opline.xbord = tonumber(bord)
      opline.ybord = tonumber(bord)
      aegisub.log(5,"Line %d: \\bord%g found\n",v-strt, bord)
    else -- only check for xbord/ybord if bord is not found (because bord overrides them)
      _,_,xbord = string.find(opline.text,"\\xbord([%d%.]+)") 
      _,_,ybord = string.find(opline.text,"\\ybord([%d%.]+)")
      if xbord then opline.xbord = tonumber(xbord); aegisub.log(5,"Line %d: \\xbord%g found\n",v-strt, xbord) end
      if ybord then opline.ybord = tonumber(ybord); aegisub.log(5,"Line %d: \\ybord%g found\n",v-strt, ybord) end
    end
    if shad then 
      opline.xshad = tonumber(shad)
      opline.yshad = tonumber(shad)
      aegisub.log(5,"Line %d: \\shad%g found\n",v-strt, shad)
    else
      _,_,xshad = string.find(opline.text,"\\xshad([%-%d%.]+)")
      _,_,yshad = string.find(opline.text,"\\yshad([%-%d%.]+)")
      if xbord then opline.xshad = tonumber(xshad); aegisub.log(5,"Line %d: \\xshad%g found\n",v-strt,xshad) end -- Yeah seriously I think I was suffering from brain damage or something.
      if ybord then opline.yshad = tonumber(yshad); aegisub.log(5,"Line %d: \\shad%g found\n",v-strt,yshad) end
    end
    if not opline.xpos then -- no way it would not find both trololo
      table.insert(accd.poserrs,{i,v})
      accd.errmsg = accd.errmsg..string.format("Line %d does not seem to have a position override tag.\n", v-strt)
    end
    --aegisub.log(5,"%d",opline.ali[1])
    if tonumber(opline.ali[1]) ~= 5 then -- the fuck is going on here
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
  math.randomseed(tonumber(tostring(os.time()):reverse())) -- because it uh makes the seed difference larger
  gui.main[3].text = tostring(math.random(100)) -- :z
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
  aegisub.set_undo_point("motion data")
end

function help(su,ac)
  local button,config = aegisub.dialog.display(gui.halp,{"Close"})
  if button=="Close" then
    init_input(su,ac)
  end
end
  
function parse_input(infile)
  local ftab = {}
  local sect, care = 0, 0
  local mocha = {}
  mocha.xpos, mocha.ypos, mocha.xscl, mocha.yscl, mocha.zrot = {}, {}, {}, {}, {}
  for line in io.lines(infile) do
    table.insert(ftab,line) -- dump the lines from the file into a table.
  end
  for keys, valu in pairs(ftab) do -- some really ugly parsing code yo (direct port from my even uglier ruby script).
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
        table.insert(mocha.xpos,tonumber(val[2])) -- is tonumber() actually necessary? Yes, because the output uses E scientific notation on occasion.
        table.insert(mocha.ypos,tonumber(val[3]))
      end
    elseif care == 1 and sect == 3 then
      if val[2] ~= "X percent" then
        table.insert(mocha.xscl,tonumber(val[2]))
        table.insert(mocha.yscl,tonumber(val[3]))
      end
    elseif care == 1 and sect == 4 then
      if val[2] ~= "Degrees" then
        table.insert(mocha.zrot,-tonumber(val[2])) -- tests indicate.
      end
    end
  end
  mocha.flength = #mocha.xpos
  assert(mocha.flength == #mocha.ypos and mocha.flength == #mocha.xscl and mocha.flength == #mocha.yscl and mocha.flength == #mocha.zrot,"The mocha data is not internally equal length.") -- make sure all of the elements are the same length (because I don't trust my own code).
  return mocha -- hurr durr
end

function frame_by_frame(sub,accd,opts)
  mocha = parse_input(opts.mocpat)
  assert(accd.totframes==mocha.flength,"Number of frames from selected lines differs from number of frames tracked.")
  local _ = nil
  if not opts.scl then
    for k,d in ipairs(mocha.xscl) do
      d = 100
      mocha.yscl[k] = 100 -- so that yscl is changed too. 
    end
  end
  local operations = {} -- create a table and put the necessary functions into it, which will save a lot of if operations in the inner loop. This was the most elegant solution I came up with.
  local eraser = {}
  if opts.pos then
    table.insert(operations,possify)
    table.insert(eraser,"\\pos%([%-%d%.]+,[%-%d%.]+%)")
  end
  if opts.scl then
    if opts.vsfilter then
      table.insert(operations,VScalify)
    else
      table.insert(operations,scalify)
    end
    table.insert(eraser,"\\fscx[%d%.]+")
    table.insert(eraser,"\\fscy[%d%.]+")
    if opts.bord then
      table.insert(eraser,"\\xbord[%d%.]+")
      table.insert(eraser,"\\ybord[%d%.]+")
      table.insert(eraser,"\\bord[%d%.]+")
      table.insert(operations,bordicate)
    end
    if opts.shad then
      table.insert(eraser,"\\xshad[%-%d%.]+")
      table.insert(eraser,"\\yshad[%-%d%.]+")
      table.insert(eraser,"\\shad[%-%d%.]+")
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
    table.insert(eraser,"\\org%([%-%d%.]+,[%-%d%.]+%)")
    table.insert(eraser,"\\frz[%-%d%.]+")
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
    for ie, ei in ipairs(eraser) do
      v.text = string.gsub(v.text,ei,"")
    end
    v.text = string.gsub(v.text,"{}","") -- Aesthetics, my friend. Aesthetics.
    local orgtext = v.text -- tables are passed as references.
    if opts.reverse then
      rstartf, rendf = rendf, rstartf
    end
    if opts.pos and not v.xpos then
      aegisub.log(1,"Line %d is being skipped because it is missing a \\pos() tag and you said to track position. Moron.",v.num) -- yeah that should do it.
    else
      if opts.reverse then
        for x = rstartf,rendf do
          local tag = "{"
          local iter = rendf-x+1 -- hm
          v.ratx = mocha.xscl[iter]/mocha.xscl[rendf] -- DIVISION IS SLOW
          v.raty = mocha.yscl[iter]/mocha.yscl[rendf]
          v.start_time = aegisub.ms_from_frame(accd.startframe+iter-1)
          v.end_time = aegisub.ms_from_frame(accd.startframe+iter)
          for vk,kv in ipairs(operations) do -- iterate through the necessary operations
            tag = tag..kv(v,mocha,opts,iter)
          end
          tag = tag.."}"
          v.text = tag..v.text -- insert the new tags in a separate block before the main one
          sub.insert(v.num+1,v)
          v.text = orgtext
        end
      else
        for x = rstartf,rendf do
          local tag = "{"
          v.ratx = mocha.xscl[x]/mocha.xscl[rstartf] -- DIVISION IS SLOW
          v.raty = mocha.yscl[x]/mocha.yscl[rstartf]
          v.start_time = aegisub.ms_from_frame(accd.startframe+x-1)
          v.end_time = aegisub.ms_from_frame(accd.startframe+x)
          for vk,kv in ipairs(operations) do -- iterate through the necessary operations
            tag = tag..kv(v,mocha,opts,x)
          end
          tag = tag.."}"
          v.text = tag..v.text -- insert the new tags in a separate block before the main one
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
  return string.format("\\pos(%g,%g)",round(xpos,opts.pround),round(ypos,opts.pround))
end

function scalify(line,mocha,opts)
  local xscl = line.xscl*line.ratx
  local yscl = line.yscl*line.raty
  return string.format("\\fscx%g\\fscy%g",round(xscl,opts.sround),round(yscl,opts.sround))
end

function bordicate(line,mocha,opts)
  local xbord = line.xbord*round(line.ratx,opts.sround) -- round beforehand to minimize random float errors
  local ybord = line.ybord*round(line.raty,opts.sround) -- or maybe that's rly fucking dumb? idklol
  if xbord == ybord then
    return string.format("\\bord%g",round(xbord,opts.sround))
  else
    return string.format("\\xbord%g\\ybord%g",round(xbord,opts.sround),round(ybord,opts.sround))
  end
end

function shadinate(line,mocha,opts)
  local xshad = line.xshad*round(line.ratx,opts.sround) -- scale shadow the same way as everything else
  local yshad = line.yshad*round(line.raty,opts.sround) -- hope it turns out as desired
  if xshad == yshad then
    return string.format("\\shad%g",round(xshad,opts.sround))
  else
    return string.format("\\xshad%g\\yshad%g",round(xshad,opts.sround),round(yshad,opts.sround))
  end
end

function VScalify(line,mocha,opts)
  local xscl = round(line.xscl*line.ratx,2)
  local yscl = round(line.yscl*line.raty,2)
  local xlowend, xhighend, xdecimal = math.floor(xscl),math.ceil(xscl),xscl%1*100
  local xstart, xend = -xdecimal, 100-xdecimal
  local ylowend, yhighend, ydecimal = math.floor(yscl),math.ceil(yscl),yscl%1*100
  local ystart, yend = -ydecimal, 100-ydecimal
  return string.format("\\fscx%d\\t(%d,%d,\\fscx%d)\\fscy%d\\t(%d,%d,\\fscy%d)",xlowend,xstart,xend,xhighend,ylowend,ystart,yend,yhighend)
end

function rotate(line,mocha,opts,iter)
  return string.format("\\org(%g,%g)\\frz%g",round(mocha.xpos[iter],opts.rround),round(mocha.ypos[iter],opts.rround),round(mocha.zrot[iter]-line.zrotd,opts.rround)) -- copypasta
end

function reverse_table(tab)
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
  if aegisub.video_size() then return true else return false end
end

aegisub.register_macro("Apply motion data","Applies properly formatted motion tracking data to selected subtitles.", prerun_czechs, isvideo)