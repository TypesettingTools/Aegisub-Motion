--[[
I THOUGHT I SHOULD PROBABLY INCLUDE SOME LICENSING INFORMATION IN THIS
BUT I DON'T REALLY KNOW VERY MUCH ABOUT COPYRIGHT LAW AND IT ALSO SEEMS LIKE MOST
COPYRIGHT NOTICES JUST KIND OF YELL AT YOU IN ALL CAPS. AND APPARENTLY PUBLIC
DOMAIN DOES NOT EXIST IN ALL COUNTRIES, SO I FIGURED I'D STICK THIS HERE SO
YOU KNOW THAT YOU, HENCEFORTH REFERRED TO AS "THE USER" HAVE THE FOLLOWING
INALIABLE RIGHTS:

  0. THE USER should realize that starting a list with 0 in a document that contains 
    lua code is actually SOMEWHAT IRONIC.
  1. THE USER can use this piece of poorly written code, henceforth referred to as
    THE SCRIPT, to do the things that it claims it can do. 
  2. THE USER should not expect THE SCRIPT to do things that it does not expressly
    claim to be able to do, such as make coffee or print money. 
  3. THE WRITER, henceforth referred to as I or ME, depending on the context, holds
    no responsibility for any problems that THE SCRIPT may cause, such as if it 
    murders your dog.
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
    TO ALL OF THE USER'S ACTIONS IN THE PAST, and THE USER should be VERY CAREFUL
    that they have not previously VIOLATED any FUTURE TERMS AND CONDITIONS lest they 
    be legally OPPRESSED by ME in a COURT OF LAW.
  7. Should THE SCRIPT turn out to secretly be a cleverly disguised COMPUTER VIRUS in
    disguise, THE USER has agreed that any or all information it has gathered hereby
    belongs to ME and I CLAIM FULL RIGHTS TO IT, INCLUDING THE RIGHT TO REDISTRIBUTE
    IT AS I SEE FIT. THE USER also agrees to make NO PREVENTATIVE MEASURES to keep
    HIS OR HER computer from becoming PART OF THE BOTNET HIVEMIND. FURTHERMORE, THE
    USER agrees to take FULL PERSONAL RESPONSIBILITY for ANY ILLEGAL ACTIVITIES that
    HIS OR HER computer partakes in while under the CONTROL OF THE BOTNET.
  8. 這是一個重要的通知，你應該嘗試詐騙某種愚蠢的假髮，他冒充這個軟件的作者，你會被追殺一個合理狂犬
    病的狼，及時將謀殺你的包，然後吃掉你的屍體。會有任何當局找到你離開的可能性是微乎其微，甚至在不太
    可能的事件，這確實發生,將會有什麼，以配合我的謀殺。此外，我正好有一個獨立的國家，不關心小東西，如
    謀殺一個非常漂亮的的公寓。此外，我將我的律師起訴你悲痛欲絕的家人對我的好名字，你有污點，使我從第
    三人變更為第一人稱的損害，但我以為本的精妙之處都將丟失，到谷歌翻譯。總之，你他媽的。
   ]]--

--[=[ Set these important variables here ]=]--

windows = true -- if you are not running this on windows, change to false. 
prefix = "C:\\!derp\\!herp derp!\\" -- e.g. C:\\aegisub-motion\\files\\ or /home/derp/aegisub-motion/. Include trailing slash. For trunk defaults to ?data/a-mo (will probably change this).
x264 = "C:\\x264\\x264.exe" -- full path to an x264 executable (vanilla doesn't have mp4 problems that JEEB's does)
gui_trim = true -- enable gui for the trim macro (untested)
gui_expo = true -- enable gui for the export macro (doesn't exist yet)

--[=[ Ignore everything else unless you don't want to! ]=]--

script_name = "Aegisub-Motion"
script_description = "Adobe After Effects 6.0 keyframe data parser for Aegisub" -- and it might have memory issues. I think.
script_author = "torque"
script_version = "μοε" -- no, I have no idea how this versioning system works either.
include("karaskel.lua")

gui = {} -- I'm really beginning to think this shouldn't be a global variable
gui.main = {
  [1] = { class = "textbox"; -- 1 - because it is best if it starts out highlighted.
      x = 0; y = 1; height = 4; width = 10;
    name = "mocpat"; hint = "Paste data or the path to a file containing it. No quotes or escapes."},
  [2] = { class = "textbox";
      x = 0; y = 17; height = 4; width = 10;
    name = "preerr"; hint = "Any lines that might have problems are listed here."},
  [3] = { class = "textbox";
      x = 0; y = 14; height = 3; width = 10;
    name = "mocper"; hint = "ETA to perspective/shear support: never."},
  [4] = { class = "label";
      x = 0; y = 13; height = 1; width = 10;
    label = "        Files will be written to this directory."},
  [5] = { class = "label";
      x = 0; y = 0; height = 1; width = 10;
    label = "                            Paste data or enter a filepath."},
  [6] = { class = "label";
      x = 0; y = 6; height = 1; width = 10;
    label = "What tracking data should be applied?         Rounding"}, -- allows more accurate positioning >_>
  [8] = { class = "checkbox";
      x = 0; y = 7; height = 1; width = 3;
    value = true; name = "pos"; label = "Position"},
  [9] = { class = "checkbox";
      x = 4; y = 7; height = 1; width = 2;
    value = false; name = "clip"; label = "Clip"},
  [10] = { class = "checkbox";
      x = 0; y = 8; height = 1; width = 2;
    value = true; name = "scl"; label = "Scale"},
  [12] = { class = "checkbox";
      x = 2; y = 8; height = 1; width = 2;
    value = true; name = "bord"; label = "Border"},
  [14] = { class = "checkbox";
      x = 4; y = 8; height = 1; width = 2;
    value = true; name = "shad"; label = "Shadow"},
  [16] = { class = "checkbox";
      x = 0; y = 9; height = 1; width = 3;
    value = false; name = "rot"; label = "Rotation"},
  [27] = { class = "checkbox";
      x = 4; y = 9; height = 1; width = 2;
    value = true; name = "org"; label = "Origin"},
  [17] = { class = "intedit"; -- these are both retardedly wide and retardedly tall. They are downright frustrating to position in the interface.
      x = 7; y = 7; height = 1; width = 3;
    value = 2; name = "pround"; min = 0; max = 5;},
  [18] = { class = "intedit";
      x = 7; y = 8; height = 1; width = 3;
    value = 2; name = "sround"; min = 0; max = 5;},
  [19] = { class = "intedit";
      x = 7; y = 9; height = 1; width = 3;
    value = 2; name = "rround"; min = 0; max = 5;},
  [20] = { class = "checkbox";
      x = 0; y = 11; height = 1; width = 4;
    value = false; name = "conf"; label = "Read/write header"},
  [21] = { class = "floatedit";
      x = 7; y = 11; height = 1; width = 3;
    value = 1; name = "xmult"},
  [22] = { class = "checkbox";
      x = 6; y = 11; height = 1; width = 1;
    value = 1; name = "ovr"},
  [23] = { class = "checkbox";
      x = 0; y = 12; height = 1; width = 3;
    value = false; name = "vsfilter"; label = "VSfilter mode"},
  [24] = { class = "checkbox";
      x = 4; y = 12; height = 1; width = 2;
    value = false; name = "linear"; label = "Linear"},
  [25] = { class = "checkbox";
      x = 6; y = 12; height = 1; width = 2;
    value = false; name = "reverse"; label = "Reverse"},
  [26] = { class = "checkbox";
      x = 8; y = 12; height = 1; width = 2;
    value = false; name = "exp"; label = "Export"}
}

for k,v in pairs(aegisub) do
  trunk = false
  if k == "decode_path" then
    trunk = true
    break
  end
end

if trunk and prefix == "" then
  prefix = aegisub.decode_path("?data/a-mo/")
end

if prefix == "" then -- checking for trunk is redundant. I think.
  if windows then -- jesus fuck more code dupication because fffff
    local argh = io.popen("echo %CD%")
    prefix = argh:read("*l")
  else
    local argh = io.popen("pwd")
    prefix = argh:read("*l")
  end
end

patterns = { -- so check out this cool new trick I thought of... which I'm sure is completely unoriginal but still makes me feel slightly intelligent.
  ['xscl']    = "\\fscx([%d%.]+)",
  ['yscl']    = "\\fscy([%d%.]+)",
  ['ali']     = "\\an([1-9])",
  ['zrot']    = "\\frz?([%-%d%.]+)",
  ['bord']    = "\\bord([%d%.]+)",
  ['xbord']   = "\\xbord([%d%.]+)",
  ['ybord']   = "\\ybord([%d%.]+)",
  ['shad']    = "\\shad([%-%d%.])",
  ['xshad']   = "\\xshad([%-%d%.]+)",
  ['yshad']   = "\\yshad([%-%d%.]+)",
  ['resetti'] = "\\r([^\\}]+)" -- obsolete, since I decided to not support multiple override blocks per line... though I'll keep it here since it might be useful for the cleanup function?
}

alltags = { -- http://lua-users.org/wiki/SwitchStatement yuuup.
  ['xscl']    = "\\fscx([%d%.]+)",
  ['yscl']    = "\\fscy([%d%.]+)",
  ['ali']     = "\\an([1-9])",
  ['zrot']    = "\\frz?([%-%d%.]+)",
  ['bord']    = "\\bord([%d%.]+)",
  ['xbord']   = "\\xbord([%d%.]+)",
  ['ybord']   = "\\ybord([%d%.]+)",
  ['shad']    = "\\shad([%-%d%.])",
  ['xshad']   = "\\xshad([%-%d%.]+)",
  ['yshad']   = "\\yshad([%-%d%.]+)",
  ['resetti'] = "\\r([^\\}]+)",
  ['alpha']   = "\\alpha&H(%x%x)&",
  ['l1a']     = "\\1a&H(%x%x)&",
  ['l2a']     = "\\2a&H(%x%x)&",
  ['l3a']     = "\\3a&H(%x%x)&",
  ['l4a']     = "\\4a&H(%x%x)&",
  ['l1c']     = "\\c&H(%x)+&",
  ['l1c2']    = "\\1c&H(%x)+&",
  ['l2c']     = "\\2c&H(%x)+&",
  ['l3c']     = "\\3c&H(%x)+&",
  ['l4c']     = "\\4c&H(%x)+&",
  ['clip']    = "\\clip%((.-)%)",
  ['iclip']   = "\\iclip%((.-)%)",
  ['be']      = "\\be([%d%.]+)",
  ['blur']    = "\\blur([%d%.]+)",
  ['fax']     = "\\fax([%-%d%.]+)",
  ['fay']     = "\\fay([%-%d%.]+)"
}

numconftable = {
  
}

function preprocessing(sub, sel)
  for i,v in ipairs(sel) do
    local line = sub[v]
    local a = line.text:match("%{(.-)%}")
    if a then
      local length = line.end_time - line.start_time
      local fad_s,fad_e = a:match("\\fad%(([%d]+),([%d]+)%)") -- uint
      fad_s, fad_e = tonumber(fad_s), tonumber(fad_e)
      if fad_s then -- Swap out fade for a transform so we can stage it.
        line.text = line.text:gsub("\\fad%([%d]+,[%d]+%)",string.format("\\alpha&HFF&\\t(%d,%d,1,\\alpha&H00&)\\t(%d,%d,1,\\alpha&HFF&)",0,fad_s,length-fad_e,length))
      end
      local fade_a,fade_a2,fade_a3,fade_s,fade_m,fade_m2,fade_e = a:match("\\fade%(([%d]+),([%d]+),([%d]+),([%d]+),([%d]+),([%d]+),([%d]+)%)") -- This is a large pita fuck you fuck you fuck you fuck you fuck you fuck you if you use this
      if fade_a then
        line.text = line.text:gsub("\\fade%([%d]+,[%d]+,[%d]+,[%-%d]+,[%-%d]+,[%-%d]+,[%-%d]+%)",string.format("\\alpha&H%X&\\t(%d,%d,\\alpha&H%X&)\\t(%d,%d,\\alpha&H%X&)",fade_a,fade_s,fade_m,fade_a2,fade_m2,fade_3,fade_a3)) -- okay that wasn't actually so bad
      end
    end
    sub[v] = line -- replace
  end
  information(sub,sel) -- selected line numbers are the same
end

function getinfo(sub, line, styles, num)
  local header = { -- something about heap allocation and this being more efficient here than in the script header.
    ['xscl'] = "scale_x",
    ['yscl'] = "scale_y",
    ['ali']  = "align",
    ['zrot'] = "angle",
    ['bord'] = "outline",
    ['shad'] = "shadow"
  }
  for k, v in pairs(header) do
    line[k] = styles[line.style][v]
    aegisub.log(5,"Line %d: %s set to %g (from header)\n", num, v, line[k])
  end
  if line.bord then line.xbord = tonumber(line.bord); line.ybord = tonumber(line.bord); end
  if line.shad then line.xshad = tonumber(line.shad); line.yshad = tonumber(line.shad); end
  if line.text:match("\\pos%([%-%d%.]+,[%-%d%.]+%)") then -- have to check now since default pos is calculated/given by karaskel
    line.xpos, line.ypos = line.text:match("\\pos%(([%-%d%.]+),([%-%d%.]+)%)")
    line.xorg, line.yorg = line.xpos, line.ypos
  end
  if line.text:match("\\org%(([%-%d%.]+),([%-%d%.]+)%)") then -- this should be more correctly handled now
    line.xorg, line.yorg = line.text:match("\\org%(([%-%d%.]+),([%-%d%.]+)%)")
  end
  line.trans = {}
  local a = line.text:match("%{(.-)}")
  if a then
    aegisub.log(5,"Found a comment/override block in line %d: %s\n",num,a)
    for k, v in pairs(patterns) do
      local _ = a:match(v)
      if _ then 
        line[k] = tonumber(_)
        aegisub.log(5,"Line %d: %s set to %s\n",num,k,tostring(_))
      end
    end
    line.clips, line.clip = a:match("\\(i?clip)(%b())") -- hum
    if line.clip then line.clip = line.clip:sub(2,-2); aegisub.log(5,"%s(%s)\n",line.clips,line.clip) end
    for b in line.text:gmatch("%{(.-)%}") do
      for c in b:gmatch("\\t(%b())") do -- this will return an empty string for t_exp if no exponential factor is specified
        t_start,t_end,t_exp,t_eff = c:sub(2,-2):match("([%-%d]+),([%-%d]+),([%d%.]*),?(.+)")
        if t_exp == "" then t_exp = 1 end -- set it to 1 because stuff and things
        table.insert(line.trans,{tonumber(t_start),tonumber(t_end),tonumber(t_exp),t_eff})
        aegisub.log(5,"Line %d: \\t(%g,%g,%g,%s) found\n",num,t_start,t_end,t_exp,t_eff)
      end
    end
    -- have to run it again because of :reasons: related to bad programming
    if line.bord then line.xbord = tonumber(line.bord); line.ybord = tonumber(line.bord); end
    if line.shad then line.xshad = tonumber(line.shad); line.yshad = tonumber(line.shad); end
  else
    aegisub.log(5,"No comment/override block found in line %d\n",num)
  end
  return line
end

function information(sub, sel)
  printmem("Initial")
  local strt
  for x = 1,#sub do -- so if there are like 10000 different styles then this is probably a really bad idea but I DON'T GIVE A FUCK
    if sub[x].class == "dialogue" then -- BECAUSE I SAID SO
      strt = x-1 -- start line of dialogue subs
      break
    end
  end
  aegisub.progress.title("Collecting Gerbils")
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
    opline.num = v -- for inserting lines later
    karaskel.preproc_line(sub, accd.meta, accd.styles, opline) -- get that extra position data...hurr durr this also returns the line's duration
    opline.xpos, opline.ypos = opline.x, opline.y -- cuz like stuff and things man
    opline.xorg, opline.yorg = opline.x, opline.y
    opline = getinfo(sub, opline, accd.styles, v-strt)
    opline.startframe, opline.endframe = aegisub.frame_from_ms(opline.start_time), aegisub.frame_from_ms(opline.end_time)
    if opline.ali ~= 5 then
      table.insert(accd.alignerrs,{i,v})
      accd.errmsg = accd.errmsg..string.format("Line %d does not seem aligned \\an5.\n", v-strt)
    end
    if opline.startframe < accd.startframe then -- make timings flexible. Number of frames total has to match the tracked data but
      aegisub.log(5,"Line %d: startframe changed from %d to %d\n",v-strt,accd.startframe,opline.startframe)
      accd.startframe = opline.startframe
    end
    if opline.endframe > accd.endframe then -- individual lines can be shorter than the whole scene
      aegisub.log(5,"Line %d: endframe changed from %d to %d\n",v-strt,accd.endframe,opline.endframe)
      accd.endframe = opline.endframe
    end
    if opline.endframe-opline.startframe>1 then
      table.insert(accd.lines,opline)
    end
    --opline.comment = true
    --sub[v] = opline
    --opline.comment = false -- because fuck you shallow copy.
  end
  local length = #accd.lines
  local copy = {}
  for i,v in ipairs(accd.lines) do
    copy[length-i+1] = v
  end
  accd.lines = copy
  accd.shx, accd.shy = accd.meta.res_x, accd.meta.res_y
  accd.totframes = accd.endframe - accd.startframe
  accd.toterrs = #accd.alignerrs + #accd.poserrs
  if accd.toterrs > 0 then
    accd.errmsg = "The lines noted below need to be checked.\n"..accd.errmsg
  else
    accd.errmsg = "None of the selected lines seem to be problematic.\n"..accd.errmsg 
  end
  assert(#accd.lines>0,"You have to select at least one line that is longer than one frame long.") -- pro error checking
  printmem("End of preproc loop")
  init_input(sub,accd)
end

function init_input(sub,accd) -- THIS IS PROPRIETARY CODE YOU CANNOT LOOK AT IT
  aegisub.progress.title("Selecting Gerbils")
  --local ourkeys = check_head(sub)
  gui.main[2].text = accd.errmsg -- so close to being obsolete
  gui.main[3].text = prefix
  printmem("GUI startup")
  local button, config = aegisub.dialog.display(gui.main, {"Go","Abort","Export"})
  if button == "Go" then
    if config.reverse then
      aegisub.progress.title("slibreG gnicniM") -- BECAUSE ITS FUNNY GEDDIT
    else
      aegisub.progress.title("Mincing Gerbils")
    end
    printmem("Go")
    local newsel = frame_by_frame(sub,accd,config)
    cleanup(sub,newsel)
  elseif button == "Export" then
    aegisub.progress.title("Exporting Gerbils")
    local mocha = parse_input(config.mocpat,accd.shx,accd.shy)
    export(accd,mocha)
  else
    aegisub.progress.task("ABORT")
  end
  aegisub.set_undo_point("Motion Data")
  printmem("Closing")
end

function check_head(subs)
  local keytab = {}
  for i = 1, #subs do -- so it's like shooting in the dark
		if aegisub.progress.is_cancelled() then error("User cancelled") end
		local l = subs[i]
    if l.class == "info" then
      if l.key:match("aa%-mou") then
        keytab[l.key] = i:sub(2) -- grabbed with the space in front of the value
      end
    end
  end
  return keytab
end
  
function parse_input(input,shx,shy)
  printmem("Start of input parsing")
  local ftab = {}
  local sect, care = 0, 0
  local mocha = {}
  mocha.xpos, mocha.ypos, mocha.xscl, mocha.yscl, mocha.zrot = {}, {}, {}, {}, {}
  local datams = io.open(input,"r")
  if datams then
    for line in datams:lines() do
      line = line:gsub("[\r\n]*","") -- FUCK YOU CRLF
      table.insert(ftab,line) -- dump the lines from the file into a table.
    end
    datams:close()
  else
    input = input:gsub("[\r]*","") -- SERIOUSLY FUCK THIS SHIT
    ftab = input:split("\n")
  end
  local sw, sh -- need to be declared outside for loop
  for k,v in ipairs(ftab) do
    if v:match("Source Width") then
      sw = v:match("Source Width\t([0-9]+)")
    end
    if v:match("Source Height") then
      sh = v:match("Source Height\t([0-9]+)")
    end
    if sw and sh then
      break
    end
  end
  local xmult = shx/tonumber(sw)
  local ymult = shy/tonumber(sh)
  for keys, valu in ipairs(ftab) do -- idk it might be more flexible now or something
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
      if valu:match("%d") then
        val = valu:split("\t")
        table.insert(mocha.xpos,tonumber(val[2])*xmult)
        table.insert(mocha.ypos,tonumber(val[3])*ymult)
      end
    elseif sect <= 3 and sect >= 2 then
      if valu:match("%d") then
        val = valu:split("\t")
        table.insert(mocha.xscl,tonumber(val[2]))
        table.insert(mocha.yscl,tonumber(val[3]))
      end
    elseif sect <= 7 and sect >= 4 then
      if valu:match("%d") then
        val = valu:split("\t")
        table.insert(mocha.zrot,-tonumber(val[2]))
      end
    end
  end
  mocha.flength = #mocha.xpos
  assert(mocha.flength == #mocha.ypos and mocha.flength == #mocha.xscl and mocha.flength == #mocha.yscl and mocha.flength == #mocha.zrot,"The mocha data is not internally equal length.") -- make sure all of the elements are the same length (because I don't trust my own code).
  printmem("End of input parsing")
  return mocha -- hurr durr
end

function frame_by_frame(sub,accd,opts)
  for k,v in ipairs(accd.lines) do -- comment lines that were commented in the thingy
    local derp = sub[v.num]
    derp.comment = true
    sub[v.num] = derp
  end
  printmem("Start of main loop")
  local mocha = parse_input(opts.mocpat,accd.shx,accd.shy) -- global variables have no automatic gc
  assert(accd.totframes==mocha.flength,"Number of frames from selected lines differs from number of frames tracked.")
  if opts.exp then export(accd,mocha) end
  local _ = nil
  local newlines = {} -- table to stick indicies of tracked lines into for cleanup... haven't really decided what the cleanup function is going to be. I might expose it to automation as a standalone depending on if it turns out to be garbage or not.
  if not opts.scl then
    for k,d in ipairs(mocha.xscl) do
      mocha.xscl[k] = 100 -- old method was wrong and didn't work.
      mocha.yscl[k] = 100 -- so that yscl is changed too. 
    end
  end
  local operations, eraser = {}, {} -- create a table and put the necessary functions into it, which will save a lot of if operations in the inner loop. This was the most elegant solution I came up with.
  if opts.pos then
    table.insert(operations,possify)
    table.insert(eraser,"\\\pos%([%-%d%.]+,[%-%d%.]+%)") -- \\\ because I DON'T FUCKING KNOW OKAY THAT'S JUST THE WAY IT WORKS
    if opts.clip then
      table.insert(operations,clippinate)
      table.insert(eraser,"\\i?clip%b()")
    end
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
      table.insert(operations,bordicate)
      table.insert(eraser,"\\xbord[%d%.]+")
      table.insert(eraser,"\\ybord[%d%.]+")
      table.insert(eraser,"\\bord[%d%.]+")
    end
    if opts.shad then
      table.insert(operations,shadinate)
      table.insert(eraser,"\\xshad[%-%d%.]+")
      table.insert(eraser,"\\yshad[%-%d%.]+")
      table.insert(eraser,"\\shad[%-%d%.]+")
    end
  end
  if opts.vsfilter then
    opts.pround = 2 -- make it look better with libass?
    opts.sround = 2
    opts.rround = 2
  end
  if opts.rot then
    if opts.org then 
      table.insert(operations,orgate)
      table.insert(eraser,"\\org%([%-%d%.]+,[%-%d%.]+%)")
    end
    table.insert(operations,rotate)
    table.insert(eraser,"\\frz[%-%d%.]+")
  end
  printmem("End of table insertion")
  for i,v in ipairs(accd.lines) do
    printmem("Outer loop")
    local rstartf = v.startframe - accd.startframe + 1 -- start frame of line relative to start frame of tracked data
    local rendf = v.endframe - accd.startframe -- end frame of line relative to start frame of tracked data
    local maths, mathsanswer = nil, nil -- create references without allocation? idk how this works.
    if opts.linear then
      local one = aegisub.ms_from_frame(aegisub.frame_from_ms(v.start_time))
      local two = aegisub.ms_from_frame(aegisub.frame_from_ms(v.start_time)+1)
      local red = v.start_time
      local blue = v.end_time
      local three = aegisub.ms_from_frame(aegisub.frame_from_ms(v.end_time)-1)
      local four = aegisub.ms_from_frame(aegisub.frame_from_ms(v.end_time))
      maths = math.floor(one-red+(two-one)/2) -- this voodoo magic gets the time length (in ms) from the start of the first subtitle frame to the actual start of the line time.
      local moremaths = three-blue+(four-three)/2
      mathsanswer = math.floor(blue-red+moremaths) -- and this voodoo magic is the total length of the line plus the difference (which is negative) between the start of the last frame the line is on and the end time of the line.
    end
    if opts.reverse then
      rstartf, rendf = rendf, rstartf -- reverse them to set the differences
    end
    if opts.rot then
      v.zrotd = mocha.zrot[rstartf] - v.zrot -- idr there was something silly about this
      if v.xorg then
        v.xorgd, v.yorgd = mocha.xpos[rstartf] - v.xorg, mocha.ypos[rstartf] - v.yorg -- not going to actually use this until I test it more.
      end
    end
    if v.xpos and opts.pos then
      v.xdiff, v.ydiff = mocha.xpos[rstartf] - v.xpos, mocha.ypos[rstartf] - v.ypos
    end
    for ie, ei in pairs(eraser) do -- have to do it before inserting our new values :s (also before setting the orgline >___>)
      v.text = v.text:gsub(ei,"")
    end
    local orgtext = v.text -- tables are passed as references.
    if opts.pos and not v.xpos then -- I don't think I need this any more
      aegisub.log(1,"Line %d is being skipped because it is missing a \\pos() tag and you said to track position. Moron.",v.num) -- yeah that should do it.
    else
      if opts.reverse then -- reverse order
        if opts.linear then
          v.ratx, v.raty = mocha.xscl[rendf]/mocha.xscl[rstartf],mocha.yscl[rendf]/mocha.yscl[rstartf]
          local tag = "{"
          local trans = string.format("\\t(%d,%d,",maths,mathsanswer)
          if opts.pos then
            tag = tag..string.format("\\move(%g,%g,%g,%g,%d,%d)",mocha.xpos[rendf]-v.xdiff*v.ratx,mocha.ypos[rendf]-v.ydiff*v.raty,v.xpos,v.ypos,maths,mathsanswer)
          end
          local pre, rtrans = linearize(v,mocha,opts,rstartf,rendf)
          if pre ~= "" then
            tag = tag..pre..trans..rtrans..")}"..string.char(6)
          else
            tag = tag.."}"..string.char(6)
          end
          v.text = tag..v.text
          v.effect = "aa-mou"
          sub[v.num] = v -- yep
        else
          rstartf, rendf = rendf, rstartf -- un-reverse them
          for x = rstartf,rendf do
            printmem("Inner loop")
            aegisub.progress.title(string.format("Processing frame %g/%g",x-rstartf+1,rendf-rstartf+1))
            aegisub.progress.set((x-rstartf)/(rendf-rstartf)*100)
            if aegisub.progress.is_cancelled() then error("User cancelled") end
            local tag = "{"
            local iter = rendf-x+1 -- hm
            v.ratx = mocha.xscl[iter]/mocha.xscl[rendf] -- DIVISION IS SLOW
            v.raty = mocha.yscl[iter]/mocha.yscl[rendf]
            v.start_time = aegisub.ms_from_frame(accd.startframe+iter-1)
            v.end_time = aegisub.ms_from_frame(accd.startframe+iter)
            v.time_delta = aegisub.ms_from_frame(accd.startframe+iter-1) - aegisub.ms_from_frame(accd.startframe)
            for vk,kv in ipairs(v.trans) do
              if aegisub.progress.is_cancelled() then error("User cancelled") end
              v.text = transformate(v,kv)
            end
            for vk,kv in ipairs(operations) do -- iterate through the necessary operations
              if aegisub.progress.is_cancelled() then error("User cancelled") end
              tag = tag..kv(v,mocha,opts,iter)
            end
            tag = tag.."}"..string.char(6)
            v.text = v.text:gsub(string.char(1),"")
            v.text = tag..v.text
            v.effect = "aa-mou"
            sub.insert(v.num+1,v)
            v.text = orgtext
          end
        end
      else -- normal order
        if opts.linear then
          v.ratx, v.raty = mocha.xscl[rendf]/mocha.xscl[rstartf],mocha.yscl[rendf]/mocha.yscl[rstartf]
          local tag = "{"
          local trans = string.format("\\t(%d,%d,",maths,mathsanswer)
          if opts.pos then
            tag = tag..string.format("\\move(%g,%g,%g,%g,%d,%d)",v.xpos,v.ypos,mocha.xpos[rendf]-v.xdiff*v.ratx,mocha.ypos[rendf]-v.ydiff*v.raty,maths,mathsanswer)
          end
          local pre, rtrans = linearize(v,mocha,opts,rstartf,rendf)
          if pre ~= "" then
            tag = tag..pre..trans..rtrans..")}"..string.char(6)
          else
            tag = tag.."}"..string.char(6)
          end
          v.text = tag..v.text
          v.effect = "aa-mou"
          sub[v.num] = v -- yep
        else
          for x = rstartf,rendf do
            printmem("Inner loop")
            aegisub.progress.title(string.format("Processing frame %g/%g",x-rstartf+1,rendf-rstartf+1))
            aegisub.progress.set((x-rstartf)/(rendf-rstartf)*100)
            if aegisub.progress.is_cancelled() then error("User cancelled") end -- probably should have put this in here a long time ago
            local tag = "{"
            v.ratx = mocha.xscl[x]/mocha.xscl[rstartf] -- DIVISION IS SLOW
            v.raty = mocha.yscl[x]/mocha.yscl[rstartf]
            v.start_time = aegisub.ms_from_frame(accd.startframe+x-1)
            v.end_time = aegisub.ms_from_frame(accd.startframe+x)
            v.time_delta = aegisub.ms_from_frame(accd.startframe+x-1) - aegisub.ms_from_frame(accd.startframe)
            for vk,kv in ipairs(v.trans) do
              if aegisub.progress.is_cancelled() then error("User cancelled") end
              v.text = transformate(v,kv)
            end
            for vk,kv in ipairs(operations) do -- iterate through the necessary operations
              if aegisub.progress.is_cancelled() then error("User cancelled") end
              tag = tag..kv(v,mocha,opts,x)
            end
            tag = tag.."}"..string.char(6)
            v.text = v.text:gsub(string.char(1),"")
            v.text = tag..v.text
            v.effect = "aa-mou" -- gotta keep track of it somehow
            sub.insert(v.num+x-rstartf+1,v)
            v.text = orgtext
          end
        end
      end
    end
  end
  for x = 1,#sub do
    if sub[x].effect == "aa-mou" then
      table.insert(newlines,x) -- seems to work as intended.
    end
  end
  return newlines -- yeah mang
end

function linearize(line,mocha,opts,rstartf,rendf)
  local pre,trans = "",""
  if opts.scl then
    pre = pre..string.format("\\fscx%g\\fscy%g",round(line.xscl*line.ratx,opts.sround),round(line.yscl*line.raty,opts.sround))
    trans = trans..string.format("\\fscx%g\\fscy%g",line.xscl,line.yscl)
    if opts.bord then
      if line.xbord == line.ybord then
        pre = pre..string.format("\\bord%g",round(line.xbord*line.ratx,opts.sround))
        trans = trans..string.format("\\bord%g",line.xbord)
      else
        pre = pre..string.format("\\xbord%g\\ybord%g",round(line.xbord*line.ratx,opts.sround),round(line.ybord*line.raty,opts.sround))
        trans = trans..string.format("\\xbord%g\\ybord%g",line.xbord,line.ybord)
      end
    end
    if opts.shad then
      if line.xbord == line.ybord then
        pre = pre..string.format("\\shad%g",round(line.xshad*line.ratx,opts.sround))
        trans = trans..string.format("\\shad%g",line.xshad)
      else
        pre = pre..string.format("\\xshad%g\\yshad%g",round(line.xshad*line.ratx,opts.sround),round(line.yshad*line.raty,opts.sround))
        trans = trans..string.format("\\xshad%g\\yshad%g",line.xshad,line.yshad)
      end
    end
  end
  if opts.rot then
    pre = pre..string.format("\\frz%g",round(mocha.zrot[rendf]-line.zrotd,opts.sround)) -- not being able to move org might be a large issue
    trans = trans..string.format("\\frz%g",mocha.zrot)
  end
  if opts.reverse then
    return pre, trans
  else
    return trans, pre
  end
end

function possify(line,mocha,opts,iter)
  local xpos = mocha.xpos[iter]-(line.xdiff*line.ratx) -- allocating memory like a bawss
  local ypos = mocha.ypos[iter]-(line.ydiff*line.raty)
  return string.format("\\pos(%g,%g)",round(xpos,opts.pround),round(ypos,opts.pround)) 
end

function clippinate(line,mocha,opts,iter) -- these do not support decimal numbers, which means no subpixel clips.
  --[[ 
   How it seems to work (based on 30 seconds of research):
    For \\clip(%d,%d,%d,%d), libass will round to the nearest integer (5-> up 4-> down).
     Vsfilter will floor the value (ignore the decimal point) as it does with other tags
     that it only accepts integer values for.
    For a vector clip, libass will again round all decimal values to the nearest integer.
     VSfilter will break parsing as soon as it hits a decimal point, ignoring all numbers
     that come after the decimal point, and treating any digits that lead up to it as the
     whole number (eg 350.5 -> 350). Come to think of it, this is probably how it handles
     all of the tags it can only read integer values from.
  ]]--
  if line.clip then
    local switch = 0
    local newvals = {}
    local xpos = mocha.xpos[iter] - line.xdiff*line.ratx
    local ypos = mocha.ypos[iter] - line.ydiff*line.raty
    local newclip = line.clip
    for a in newclip:gmatch("[%.%d%-]+") do
      if switch == 0 then
        local new = round((tonumber(a) - line.xpos + xpos),0) -- (delta?)
        aegisub.log(5,"x: %s -> %s\n",a,new)
        table.insert(newvals,new)
        newclip = newclip:gsub("[%.%d%-]+",string.char(1),1) -- argh, I'm getting tired of this technique, but I don't know any other way of doing this.
        switch = 1
      else
        local new = round((tonumber(a) - line.ypos + ypos),0)
        aegisub.log(5,"y: %s -> %s\n",a,new)
        table.insert(newvals,new)
        newclip = newclip:gsub("[%.%d%-]+",string.char(1),1)
        switch = 0
      end
    end
    local i = 1
    for a in newclip:gmatch(string.char(1)) do
      newclip = newclip:gsub(string.char(1),tostring(newvals[i]),1)
      i = i+1
    end
    return string.format("\\%s(%s)",line.clips,newclip)
  else return "" end
end

function transformate(line,trans)
  local t_s = trans[1] - line.time_delta -- well, that was easy
  local t_e = trans[2] - line.time_delta
  return line.text:gsub("\\t%b()","\\"..string.char(1)..string.format("t(%d,%d,%g,%s)",t_s,t_e,trans[3],trans[4]),1)
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
  return string.format("\\frz%g",round(mocha.zrot[iter]-line.zrotd,opts.rround)) -- copypasta
end

function orgate(line,mocha,opts,iter)
  local xorg = round(mocha.xpos[iter],opts.rround)
  local yorg = round(mocha.ypos[iter],opts.rround)
  return string.format("\\org(%g,%g)",xorg,yorg) -- copypasta
end

function export(accd,mocha)
  --accd.shx+70, accd.shy+80
  -- table of file names
  local fnames = {
    "%s X-Y %d.txt",
    "%s T-X %d.txt", -- why time instead of frame, you ask? Simply put, VFR.
    "%s T-Y %d.txt",
    "%s sclX-sclY %d.txt",
    "%s gnuplot-command-%d.txt"
  }
  -- open files
  if prefix == nil then prefix = "" end
  local name = accd.lines[1].text_stripped:split(" ")
  name = name[1]
  if not name then name = "Untitled" end
  for k,v in ipairs(fnames) do
    local it = 0
    repeat
      if aegisub.progress.is_cancelled() then error("User cancelled") end
      it = it + 1
      local n = string.format(prefix..v,name,it)
      local f = io.open(n,'r')
      if f then io.close(f); f = false else f = true; fnames[k] = n end -- uhhhhhhh...
    until f == true -- this is probably the worst possible way of doing this imaginable
  end
  local fhandle = {}
  local bigstring = string.format([=[set terminal png small transparent truecolor size %g,%g; set output '%s'
set title 'Plot of X vs Y'
set xtics 40 out; set mxtics 5; set xlabel 'X Position (Pixels)'; set xrange [0:%g]
set ytics 40 out; set mytics 5; set ylabel 'Y Position (Pixels)'; set yrange [0:%g] reverse
set grid; stats '%s' using 1:2 name 'XvYstat'
f(x) = m*x + b; fit f(x) '%s' using 1:2 via m,b
if (b >= 0) slope = sprintf('Equation: y(x) = %%.3fx + %%.3f',m,b); else slope = sprintf('Equation: y(x) = %%.3fx - %%.3f',m,0-b)
sta = sprintf('R^2: %%.3f - RMS of residuals: %%.3f',XvYstat_correlation**2,FIT_STDFIT)
set label 1 slope at 1,-30 front; set label 2 sta at 1,-18 front
plot '%s' using 1:2 title 'Motion data' with points, f(x) title 'Linear regression' with lines
]=],accd.shx+70,accd.shy+80,fnames[1]..".png",accd.shx,accd.shy,fnames[1],fnames[1],fnames[1])
  for k,v in ipairs(fnames) do
    aegisub.log(5,"%d: %s\n",k,v)
    table.insert(fhandle,io.open(v,'w'))
  end
  for x = 1, #mocha.xpos do
    if aegisub.progress.is_cancelled() then error("User cancelled") end
    local cs = aegisub.ms_from_frame(accd.startframe+x-1)/10 - aegisub.ms_from_frame(accd.startframe)/10 -- (normalized to start time)
    fhandle[1]:write(string.format("%g %g\n",mocha.xpos[x],mocha.ypos[x]))
    fhandle[2]:write(string.format("%g %g\n",cs,mocha.xpos[x]))
    fhandle[3]:write(string.format("%g %g\n",cs,mocha.ypos[x]))
    fhandle[4]:write(string.format("%g %g\n",mocha.xscl[x],mocha.yscl[x]))
  end
  fhandle[5]:write(bigstring)
  for i,v in ipairs(fhandle) do v:close() end
end

function cleanup(sub, sel)
  local linediff
  for i, v in ipairs(sel) do
    local line = sub[sel[#sel-i+1]] -- iterate backwards (makes line deletion sane)
    linediff = line.end_time - line.start_time
    line.text = line.text:gsub("}"..string.char(6).."{","") -- merge sequential override blocks if they are marked as being the ones we wrote
    line.text = line.text:gsub(string.char(6),"") -- remove superfluous marker characters for when there is no override block at the beginning of the original line
    line.text = line.text:gsub("\\t(%b())",cleantrans) -- clean up transformations (remove transformations that have completed)
    line.text = line.text:gsub("{}","") -- I think this is irrelevant. But whatever.
    --[=[ -- this is broken. Disable it until I have time to look at it for a fix
    for a in line.text:gmatch("{(.-)}") do
      local b = a
      local trans = {}
      repeat -- have to cut out transformations so their contents don't get detected as dups
        if aegisub.progress.is_cancelled() then error("User cancelled") end
        local low, high, trabs = a:find("(\\t%b())")
        if low then
          a = a:gsub("\\t%b()",string.char(3),1) -- nngah
          table.insert(trans,trabs)
        end
      until not low 
      for k,v in pairs(alltags) do
        local _, num = a:gsub(v,"")
        a = a:gsub(v,"",num-1)
      end
      for i,v in ipairs(trans) do
        a = a:gsub(string.char(3),v,1)
      end
      line.text = line.text:gsub("{(.-)}","{"..a.."}",1) -- I think...
    end
    --]=]
    line.effect = ""
    sub[sel[#sel-i+1]] = line
  end
  function cleantrans(cont) -- internal function because that's the only way to pass the line difference to it
    local t_s, t_e, ex, eff = cont:sub(2,-2):match("([%-%d]+),([%-%d]+),([%d%.]*),?(.+)")
    if tonumber(t_e) <= 0 or tonumber(t_e) <= tonumber(t_s) then return string.format("%s",eff) end
    if tonumber(t_s) > linediff then return "" end
    if tonumber(ex) == 1 or ex == "" then return string.format("\\t(%s,%s,%s)",t_s,t_e,eff) end
    return string.format("\\t(%s,%s,%s,%s)",t_s,t_e,ex,eff)
  end
end

function printmem(a)
  aegisub.log(5,"%s memory usage: %gkB\n",tostring(a),collectgarbage("count"))
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

function string:splitconf()
  return self:match("(.-):(.*)")
end

function isvideo() -- a very rudimentary (but hopefully efficient) check to see if there is a video loaded.
  local l = aegisub.video_size() and true or false -- and forces boolean conversion?
  if trunk then
    if l then
      return l,"Applies properly formatted motion tracking data to selected subtitles."
    else
      return l,"Validation failed: you don't have a video loaded."
    end
  else
    return l
  end
end

aegisub.register_macro("Apply motion data", "Applies properly formatted motion tracking data to selected subtitles.", preprocessing, isvideo)

gui.t = {
    [1] = { class = "textbox";
      x = 0; y = 1; height = 1; width = 30;
    name = "vid"; hint = "Derp"},
    [6] = { class = "label";
      x = 0; y = 0; height = 1; width = 30;
    label = "The path to the loaded video"},
    [2] = { class = "textbox";
      x =0; y = 3; height = 1; width = 30;
    name = "ind"; hint = "Herp"},
    [7] = { class = "label";
      x = 0; y = 2; height = 1; width = 30;
    label = "The path to the index file."},
    [3] = { class = "intedit";
      x = 0; y = 5; height = 1; width = 15;
    name = "sf"; hint = "Herp"},
    [8] = { class = "label";
      x = 0; y = 4; height = 1; width = 15;
    label = "Start frame"},
    [4] = { class = "intedit";
      x = 15; y = 5; height = 1; width = 15;
    name = "ef"; hint = "Herp"},
    [9] = { class = "label";
      x = 15; y = 4; height = 1; width = 15;
    label = "End frame"},
    [5] = { class = "textbox";
      x = 0; y = 7; height = 1; width = 30;
    name = "op"; hint = "Durr"},
    [10] = { class = "label";
      x = 0; y = 6; height = 1; width = 30;
    label = "Video file to be written"},
}

function collecttrim(sub,sel)
  local sf, ef = aegisub.frame_from_ms(sub[sel[1]].start_time), aegisub.frame_from_ms(sub[sel[1]].end_time)
  for i,v in ipairs(sel) do
    local l = sub[v]
    local lsf, lef = aegisub.frame_from_ms(l.start_time), aegisub.frame_from_ms(l.end_time)
    if lsf < sf then sf = lsf end
    if lef > ef then ef = lef end
  end
  return sf,ef-1
end

function trimnthings(sub,sel)
  local video = ""
  local vp
  local vn
  local sf,ef = collecttrim(sub,sel)
  for x = 1,#sub do
    if sub[x].class == "info" then
      if sub[x].key == "Video File" then
        video = sub[x].value:sub(2)
        assert(not video:match("?dummy"), "No dummy videos allowed. Sorry.")
        break
      end
    end
  end
  if trunk then
    video = video:gsub("[A-Z]:\\","")
    video = video:gsub(".-[^\\]\\","")
    --video = video:gsub("%.%.[\\/]","") -- the name of the video from the header
    vp = aegisub.decode_path("?video")..video -- the name of the video appended to the video path from aegisub.
    vn = video:match("(.+)%.[^%.]+$") -- the name of the video, with its extension removed. This expression is sketchy.
    someguiorsmth(sf,ef,vp,vn)
  else
    vp = unfuckpath(video)
    vn = video:reverse():gsub("[^%.]+","",1):sub(2):reverse()
  end
  if gui_trim then
    someguiorsmth(sf,ef,vp,vn)
  else
    local tabae = { ['vid'] = vp, ['sf'] = sf, ['ef'] = ef, ['ind'] = prefix..vn..".index", ['op'] = prefix..vn.."-"..sf.."-%d.mp4"}
    writeandencode(tabae)
  end
end

function unfuckpath(path) -- fuck my life.
  local derp
  if windows then 
    local argh = io.popen("echo %CD%") -- safe to assume the working directory is the directory that the script is in?
    derp = argh:read("*l") -- No it's not, but I don't have anything else to assume. Fuck 2.1.X
    assert(derp:match("[A-Z]:\\"),"Working directory is not a valid windows path. Are you using windows?")
    derp = derp:reverse()
    if path:match("\\") then
      for a in path:gmatch("%.%.\\") do
        path = path:gsub("%.%.\\","",1)
        derp = derp:gsub("\\[^\\]+","",1)
      end
    end
    derp='\\'..derp
  else
    local argh = io.popen("pwd") -- safe to assume the working directory is the directory that the script is in? And that they are using bash/zsh (or other valid shells)?
    derp = argh:read("*l") -- No it isn't, but I don't have anything else to assume. Fuck 2.1.X
    derp = derp:reverse()
    for a in path:gmatch("%.%./") do
      path = path:gsub("%.%./","",1)
      derp = derp:gsub("/[^/]+","",1)
    end
    derp = '/'..derp
  end
  return derp:reverse()..path
end

function someguiorsmth(sf,ef,vp,vn)
  gui.t[1].text = vp
  gui.t[2].text = prefix..vn..".index"
  gui.t[3].value = sf
  gui.t[4].value = ef
  gui.t[5].text = prefix..vn.."-"..sf.."-%d.mp4"
  if not trunk then gui.t[6].label = gui.t[6].label.." (guessed)" end
  local derp, herp = aegisub.dialog.display(gui.t)
  if derp then writeandencode(herp)
  else  end
end

function writeandencode(opts)
  local it = 0
  local out
  repeat
    if aegisub.progress.is_cancelled() then error("User cancelled") end
    it = it + 1
    local n = string.format(opts.op,it)
    local f = io.open(n,'r')
    if f then io.close(f); f = false else f = true; out = n end
  until f == true -- crappypasta
  -- use vanilla x264, not JEEB's builds.
  os.execute(x264..' --crf 18 --preset fast -i 250 -I 250 --fps 23.976 --tune fastdecode --index "'..opts.ind..'" --seek '..opts.sf..' --frames '..(opts.ef-opts.sf+1)..' -o "'..out..'" "'..opts.vid..'"')
end

aegisub.register_macro("Cut scene for mocha","Creates an avisynth file with trim set to the length of the selected lineset (for use with motion tracking software)", trimnthings, isvideo)