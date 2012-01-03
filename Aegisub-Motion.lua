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
    belongs to ME and I CLAIM FULL RIGHTS OF IT, INCLUDING THE RIGHT TO REDISTRIBUTE
    IT AS I SEE FIT. THE USER also agrees to make NO PREVENTATIVE MEASURES to keep
    HIS OR HER computer from becoming PART OF THE BOTNET HIVEMIND. FURTHERMORE, THE
    USER agrees to take FULL PERSONAL RESPONSIBILITY for ANY ILLEGAL ACTIVITIES that
    HIS OR HER computer partakes in while under the CONTROL OF THE BOTNET.
  8. 這是一個重要的通知，你應該嘗試詐騙某種愚蠢的假髮，他冒充這個軟件的作者，你會被追殺一個合理狂犬
    病的狼，及時將謀殺你的包，然後吃掉你的屍體。會有任何當局找到你離開的可能性是微乎其微，甚至在不太
    可能的事件，這確實發生,將會有什麼，以配合我的謀殺。此外，我正好有一個獨立的國家，不關心小東西，如
    謀殺一個非常漂亮的的公寓。此外，我將我的律師起訴你悲痛欲絕的家人對我的好名字，你有污點，使我從第
    三人變更為第一人稱的損害，但我以為本的精妙之處都將丟失，到谷歌翻譯。總之，你他媽的。
--]]

script_name = "Aegisub-Motion"
script_description = "Adobe After Effects 6.0 keyframe data parser for Aegisub" -- also it suffers from memory leaks
script_author = "torque"
script_version = "v0.1.lessbad" -- no, I have no idea how this versioning system works either.
include("karaskel.lua")

gui = {} -- I'm really beginning to think this shouldn't be a global variable
gui.main = {
  [1] = { class = "textbox"; -- 1 - because it is best if it starts out highlighted.
      x =0; y = 1; height = 4; width = 10;
    name = "mocpat"; hint = "Paste data or the path to a file containing it. No quotes or escapes."},
  [2] = { class = "textbox";
      x = 0; y = 17; height = 4; width = 10;
    name = "preerr"; hint = "Any lines that might have problems are listed here."},
  [3] = { class = "textbox";
      x = 0; y = 14; height = 3; width = 10;
    name = "mocper"; hint = "ETA to perspective/shear support: never."},
  [4] = { class = "label";
      x = 0; y = 13; height = 1; width = 10;
    label = "                                             MOTD"}, --"  Enter the file to the path containing your shear/perspective data."},
  [5] = { class = "label";
      x = 0; y = 0; height = 1; width = 10;
    label = "                 Paste data or enter a filepath."},
  -- GIVE ME SOME (WHITE)SPACE
  [6] = { class = "label";
      x = 0; y = 6; height = 1; width = 10;
    label = "What tracking data should be applied?         Rounding"}, -- allows more accurate positioning >_>
  [8] = { class = "checkbox";
      x = 0; y = 7; height = 1; width = 3;
    value = true; name = "pos"; label = "Position"},
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

gui.motd = {
  "The culprit was a huge truck.";
  "Error 0x0045AF: Runtime requested to be terminated in an unusual fashion.";
  "Powered by 100% genuine sweatshop child laborers.";
  "vsfilter hates you.";
  "OFF DA RAILZ"
}

function preproc(sub, sel)
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
    printmem("Preproc loop")
    local opline = table.copy(sub[v]) -- I have no idea if a shallow copy is even an intelligent thing to do here
    opline.num = v -- this is for, uh, later.
    opline.trans = {}
    karaskel.preproc_line(sub, accd.meta, accd.styles, opline) -- get that extra position data
    aegisub.log(5,"Line %d's style name is: %s\n",v-strt,opline.style) -- lines with more than one style can sick a duck (see: \r[stylename])
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
    --local pre,ftag = opline.text:match("(.-){(.-)}") -- so this is what they mean by an edge case. I think. Either way, it's annoying as hell.
    opline.xpos,opline.ypos = opline.text:match("\\pos%(([%-%d%.]+),([%-%d%.]+)%)") -- always the first one
    opline.xorg,opline.yorg = opline.text:match("\\org%(([%-%d%.]+),([%-%d%.]+)%)") -- idklol
    opline.startframe, opline.endframe = aegisub.frame_from_ms(opline.start_time), aegisub.frame_from_ms(opline.end_time)
    local length = opline.end_time - opline.start_time
    opline.things = opline.text:find("{") -- really going for descriptive variable names now
    local a = opline.text:match("%{(.-)%}") -- this will find comment/override tags yo (on an unrelated note, the .- lazy repition is nice. It's shorter than .+? at least.)
    if a then
      local fad_s,fad_e = a:match("\\fad%(([%d]+),([%d]+)%)") -- uint
      fad_s, fad_e = tonumber(fad_s), tonumber(fad_e)
      if fad_s then -- Swap out fade for a transform so we can stage it. Do it before checking for transforms, so it will be picked up.
        if fad_s == 0 and fad_e > 0 then
          opline.text = opline.text:gsub("\\fad%([%d]+,[%d]+%)",string.format("\\alpha&H00&\\t(%d,%d,1,\\alpha&HFF&)",length-fad_e,length))
        elseif fad_s > 0 and fad_e == 0 then
          opline.text = opline.text:gsub("\\fad%([%d]+,[%d]+%)",string.format("\\alpha&HFF&\\t(%d,%d,1,\\alpha&H00&)",0,fad_s))
        elseif fad_s > 0 and fad_e > 0 then
          opline.text = opline.text:gsub("\\fad%([%d]+,[%d]+%)",string.format("\\alpha&HFF&\\t(%d,%d,1,\\alpha&H00&)\\t(%d,%d,1,\\alpha&HFF&)",0,fad_s,length-fad_e,length))
        else 
          opline.text = opline.text:gsub("\\fad%([%d]+,[%d]+%)","") -- GET RID OF THAT USELESS SHIT
        end
      end
      local fade_a,fade_a2,fade_a3,fade_s,fade_m,fade_m2,fade_e = a:match("\\fade%(([%d]+),([%d]+),([%d]+),([%d]+),([%d]+),([%d]+),([%d]+)%)") -- This is a large pita fuck you fuck you fuck you fuck you fuck you fuck you if you use this
      opline.text = opline.text:gsub("\\(i?)clip%(([-%d]+,[-%d]+,[-%d]+,[-%d]+)%)","\\%1clip%2") -- necessary because I can't think of a \t regex that will work properly without it.
    end
    a = opline.text:match("%{(.-)%}") -- because I am too stupid to find a better way to do this
    if a then
      aegisub.log(5,"Found a comment/override block in line %d: %s\n",v-strt,a)
      local fx = a:match("\\fscx([%d%.]+)") -- why was I using string.find before? I can't even remember.
      local fy = a:match("\\fscy([%d%.]+)") -- these should all be gc'd after this loop
      local ali = a:match("\\an([1-9])")
      local frz = a:match("\\frz?([%-%d%.]+)") -- \fr is an alias for \frz
      local bord = a:match("\\bord([%d%.]+)")
      local xbord = a:match("\\xbord([%d%.]+)")
      local ybord = a:match("\\ybord([%d%.]+)")
      local shad = a:match("\\shad([%-%d%.])")
      local xshad = a:match("\\xshad([%-%d%.]+)")
      local yshad = a:match("\\yshad([%-%d%.]+)")
      local resetti = a:match("\\r([^\\|}]+)") -- not sure I actually want to support this
      for b in opline.text:gfind("%{(.-)%}") do
        for t_start,t_end,t_exp,t_eff in b:gfind("\\t%(([%-%d]+),([%-%d]+),([%d%.]*),?(.-)%)") do -- this will return an empty string for t_exp if no exponential factor is specified
          if t_exp == "" then t_exp = 1 end -- set it to 1 because stuff and things
          table.insert(opline.trans,{tonumber(t_start),tonumber(t_end),tonumber(t_exp),t_eff}); aegisub.log(5,"Line %d: \\t(%g,%g,%g,%s) found\n",v-strt,t_start,t_end,t_exp,t_eff)
        end
      end
      if fx then opline.xscl = tonumber(fx); aegisub.log(5,"Line %d: \\fscx%g found\n",v-strt, fx) end
      if fy then opline.yscl = tonumber(fy); aegisub.log(5,"Line %d: \\fscy%g found\n",v-strt, fy) end
      if bord then opline.xbord = tonumber(bord); opline.ybord = tonumber(bord); aegisub.log(5,"Line %d: \\bord%g found\n",v-strt, bord) end
      if xbord then opline.xbord = tonumber(xbord); aegisub.log(5,"Line %d: \\xbord%g found\n",v-strt, xbord) end
      if ybord then opline.ybord = tonumber(ybord); aegisub.log(5,"Line %d: \\ybord%g found\n",v-strt, ybord) end
      if shad then opline.xshad = tonumber(shad); opline.yshad = tonumber(shad); aegisub.log(5,"Line %d: \\shad%g found\n",v-strt, shad) end
      if xshad then opline.xshad = tonumber(xshad); aegisub.log(5,"Line %d: \\xshad%g found\n",v-strt, xshad) end
      if yshad then opline.yshad = tonumber(yshad); aegisub.log(5,"Line %d: \\yshad%g found\n",v-strt, yshad) end
      if frz then opline.zrot = tonumber(frz); aegisub.log(5,"Line %d: \\frz%g found\n",v-strt, frz) end
      if ali then opline.ali = tonumber(ali); aegisub.log(5,"Line %d: \\an%d found\n",v-strt, ali) end -- the final \an is the one that's used.
    else
      aegisub.log(5,"No comment/override block found in line %d: %s\n",v-strt,a)
    end
    if not opline.xpos or not opline.ypos then -- just to be safe
      table.insert(accd.poserrs,{i,v})
      accd.errmsg = accd.errmsg..string.format("Line %d does not seem to have a position override tag.\n", v-strt)
    end
    --aegisub.log(5,"%d",opline.ali)
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
  copy = nil -- DOING MY OWN GARBAGE COLLECTION NOW LIKE A PRO
  --accd.lvidx, accd.lvidy = aegisub.video_size() -- this is p. much irrelevant now
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
  gui.main[2].text = accd.errmsg -- insert our error messages
  local rand = ((os.clock()*os.time()+os.clock())*100) -- I suppose it's bad if this gives more variation than does math.random().
  gui.main[3].text = gui.motd[math.floor(rand%5)+1] -- this would work a lot better with more than 4 items
  printmem("GUI startup")
  local button, config = aegisub.dialog.display(gui.main, {"Go","Abort"})
  if button == "Go" then
    if config.reverse then
      aegisub.progress.title("slibreG gnicniM") -- BECAUSE ITS FUNNY GEDDIT
    else
      aegisub.progress.title("Mincing Gerbils")
    end
    printmem("Go")
    local newsel = frame_by_frame(sub,accd,config)
    for k,v in ipairs(newsel) do
      aegisub.log(0,"%g\n",v)
    end
  elseif button == "Help" then
    aegisub.progress.title("Helping Gerbils?")
    help(sub,accd)
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
        --aegisub.log(0,string.format("[%d] = %s: %s\n",tostring(i),tostring(l.key),l.value:match(" (.+)")))
        keytab[l.key] = i -- grabbed with the space in front of the value? Eurgh.
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
    end--]]
  end
  mocha.flength = #mocha.xpos
  assert(mocha.flength == #mocha.ypos and mocha.flength == #mocha.xscl and mocha.flength == #mocha.yscl and mocha.flength == #mocha.zrot,"The mocha data is not internally equal length.") -- make sure all of the elements are the same length (because I don't trust my own code).
  printmem("End of input parsing")
  return mocha -- hurr durr
end

function frame_by_frame(sub,accd,opts)
  printmem("Start of main loop")
  local mocha = parse_input(opts.mocpat,accd.shx,accd.shy) -- global variables have no automatic gc
  assert(accd.totframes==mocha.flength,"Number of frames from selected lines differs from number of frames tracked.")
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
    table.insert(operations,rotate)
    table.insert(eraser,"\\\org%([%-%d%.]+,[%-%d%.]+%)")
    table.insert(eraser,"\\frz[%-%d%.]+")
  end
  --table.insert(eraser,"{}") -- I think this is redundant with the next line
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
    if opts.pos and not v.xpos then
      aegisub.log(1,"Line %d is being skipped because it is missing a \\pos() tag and you said to track position. Moron.",v.num) -- yeah that should do it.
    else
      if opts.reverse then -- reverse order
        rstartf, rendf = rendf, rstartf -- un-reverse them
        if opts.linear then
          local tag = "{"
          local trans = string.format("\\t(%d,%d,",maths,mathsanswer)
          if opts.pos then
            tag = tag..string.format("\\move(%g,%g,%g,%g,%d,%d)",mocha.xpos[rstartf]-v.xdiff*ratx,mocha.ypos[rstartf]-v.ydiff*raty,v.xpos,v.ypos,maths,mathsanswer)
          end
          local pre, rtrans = linearize(v,mocha,opts,rendf,rstartf)
          if pre ~= "" then
            tag = tag..pre..trans..rtrans..")}"
          else
            tag = tag.."}"
          end
          v.text = tag..v.text
          sub[v.num] = v -- yep
        else
          for x = rstartf,rendf do
            printmem("Inner loop")
            if aegisub.progress.is_cancelled() then error("User cancelled") end
            local tag = "{"
            local iter = rendf-x+1 -- hm
            v.ratx = mocha.xscl[iter]/mocha.xscl[rendf] -- DIVISION IS SLOW
            v.raty = mocha.yscl[iter]/mocha.yscl[rendf]
            v.start_time = aegisub.ms_from_frame(accd.startframe+iter-1)
            v.end_time = aegisub.ms_from_frame(accd.startframe+iter)
            v.time_delta = aegisub.ms_from_frame(accd.startframe+iter-1) - aegisub.ms_from_frame(accd.startframe)
            for vk,kv in ipairs(v.trans) do
              v.text = transformate(v,kv)
            end
            for vk,kv in ipairs(operations) do -- iterate through the necessary operations
              tag = tag..kv(v,mocha,opts,iter)
            end
            tag = tag.."}"
            v.text = v.text:gsub(string.char(1),"")
            v.text = tag..v.text
            if v.things == 1 then
              v.text = v.text:gsub("}{","",1)
            end
            v.effect = "aa-mou"
            sub.insert(v.num+1,v)
            v.text = orgtext
          end
        end
      else -- normal order
        if opts.linear then
          local tag = "{"
          local trans = string.format("\\t(%d,%d,",maths,mathsanswer)
          if opts.pos then
            tag = tag..string.format("\\move(%g,%g,%g,%g,%d,%d)",v.xpos,v.ypos,mocha.xpos[rendf]-v.xdiff*ratx,mocha.ypos[rendf]-v.ydiff*raty,maths,mathsanswer)
          end
          local pre, rtrans = linearize(v,mocha,opts,rstartf,rendf)
          if pre ~= "" then
            tag = tag..pre..trans..rtrans..")}"
          else
            tag = tag.."}"
          end
          v.text = tag..v.text
          sub[v.num] = v -- yep
        else
          for x = rstartf,rendf do
            printmem("Inner loop")
            if aegisub.progress.is_cancelled() then error("User cancelled") end -- probably should have put this in here a long time ago
            local tag = "{"
            v.ratx = mocha.xscl[x]/mocha.xscl[rstartf] -- DIVISION IS SLOW
            v.raty = mocha.yscl[x]/mocha.yscl[rstartf]
            v.start_time = aegisub.ms_from_frame(accd.startframe+x-1)
            v.end_time = aegisub.ms_from_frame(accd.startframe+x)
            v.time_delta = aegisub.ms_from_frame(accd.startframe+x-1) - aegisub.ms_from_frame(accd.startframe)
            for vk,kv in ipairs(v.trans) do
              v.text = transformate(v,kv)
            end
            for vk,kv in ipairs(operations) do -- iterate through the necessary operations
              tag = tag..kv(v,mocha,opts,x)
            end
            tag = tag.."}"
            v.text = v.text:gsub(string.char(1),"")
            v.text = tag..v.text
            if v.things == 1 then
              v.text = v.text:gsub("}{","",1)
            end
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

function linearlize(line,mocha,opts,rstartf,rendf)
  local ratx,raty = mocha.xscl[rendf]/mocha.xscl[rstartf],mocha.yscl[rendf]/mocha.yscl[rstartf]
  local pre,trans = "",""
  if opts.scl then
    pre = pre..string.format("\\fscx%g\\fscy%g",round(line.xscl*ratx,opts.sround),round(line.yscl*raty,opts.sround))
    trans = trans..string.format("\\fscx%g\\fscy%g",line.xscl,line.yscl)
    if opts.bord then
      if line.xbord == line.ybord then
        pre = pre..string.format("\\bord%g",round(line.xbord*ratx,opts.sround))
        trans = trans..string.format("\\bord%g",line.xbord)
      else
        pre = pre..string.format("\\xbord%g\\ybord%g",round(line.xbord*ratx,opts.sround),round(line.ybord*raty,opts.sround))
        trans = trans..string.format("\\xbord%g\\ybord%g",line.xbord,line.ybord)
      end
    end
    if opts.shad then
      if line.xbord == line.ybord then
        pre = pre..string.format("\\shad%g",round(line.xshad*ratx,opts.sround))
        trans = trans..string.format("\\shad%g",line.xshad)
      else
        pre = pre..string.format("\\xshad%g\\yshad%g",round(line.xshad*ratx,opts.sround),round(line.yshad*raty,opts.sround))
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

function transformate(line,trans)
  local t_s = trans[1] - line.time_delta -- well, that was easy
  local t_e = trans[2] - line.time_delta
  return line.text:gsub("\\t%([%-%d]+,[%-%d]+,[%d%.]*,?.-%)","\\"..string.char(1)..string.format("t(%d,%d,%g,%s)",t_s,t_e,trans[3],trans[4]),1) -- I hate how messy this expression is
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

function isvideo() -- a very rudimentary (but hopefully efficient) check to see if there is a video loaded.
  return aegisub.video_size() and true or false -- and forces boolean conversion
end

aegisub.register_macro("Apply motion data","Applies properly formatted motion tracking data to selected subtitles.", preproc, isvideo)