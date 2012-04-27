  --[=[ If a full path is provided, that config file will always be used. If a filename is provided,
        then we attempt to open that file in the script directory, and if that fails, then we open
        it in the aegisub userdata directory (%APPDATA%/Aegisub or ~/.aegisub). This allows different
        settings (prefix, etc) per-project if you desire.]=]--
config_file = "aegisub-motion.conf" -- e.g. C:\\path\\to the\\a-mo.conf or /home/path to/the/aegi-moti.conf
  --[=[ YOU ARE LEGALLY BOUND AND GAGGED BY THE TERMS AND CONDITIONS OF THE LICENSE,
        EVEN IF YOU HAVEN'T READ THEM. ]=]--
      
--[=[
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
  8. This is an IMPORTANT NOTIFICATION, you should try to defraud SOME STUPID WIG
    posing as THE AUTHOR OF THIS SOFTWARE, you will be hunted down to a REASONABLE
    RABIES WOLF, in a timely manner to THE MURDER OF YOUR PACKAGE, and then eat YOUR
    BODY. There will be ANY OF THE AUTHORITIES to find you the possibility of leaving
    are VERY SLIM, even IN THE UNLIKELY EVENT THIS DOES OCCUR, will have to cope with
    the MURDER. In addition, I HAPPEN TO HAVE an independent country, DO NOT CARE
    ABOUT THE LITTLE THINGS, such as THE MURDER OF A BEAUTIFUL APARTMENT. Besides, I
    have MY LAWYER to prosecute THE GOOD NAME OF YOUR DISTRAUGHT FAMILY, you have a
    stain, so I CHANGE FROM THIRD PERSON TO FIRST PERSON HARM, but I think this
    subtlety will be lost to Google Translate. In short, FUCK YOU.
  9. THE USER understands that while the inclusion of a CHINESE MOONRUNE CLAUSE in
    the LICENSE AGREEMENT was VITALLY IMPORTANT, it unfortunately HAD TO BE REMOVED
    because THE LUA PARSER IS EVER SO FRAGILE and has been known to do VERY CONFUSING
    THINGS in the face of MULTIBYTE CHARACTERS, even when THE SCRIPT is encoded as
    UTF-8. A HIGH QUALITY translation of the PREVIOUS TERM HAS BEEN SUBSTITUTED IN
    for the FORESEEABLE FUTURE. Should it raise ANY QUESTIONS, THE USER is welcome to
    JUST GO AHEAD AND JUMP OFF OF A BRIDGE because his or her stupidity is OBVIOUSLY
    INCURABLE.
  ]=]--

script_name = "Aegisub-Motion"
script_description = "A set of tools for simplifying the process of creating and applying motion tracking data with Aegisub." -- and it might have memory issues. I think.
script_author = "torque"
script_version = "μοε-RC1" -- no, I have no idea how this versioning system works either.
require "karaskel"

gui = {} -- I'm really beginning to think this shouldn't be a global variable
gui.main = { -- todo: change these to be more descriptive.
  linespath = { class = "textbox"; name = "linespath"; hint = "Paste data or the path to a file containing it. No quotes or escapes.";
                x = 0; y = 1; height = 4; width = 10;},
  pref      = { class = "textbox"; name = "pref"; hint = "The prefix";
                x = 0; y = 14; height = 3; width = 10;},
  preflabel = { class = "label"; label = "                     Files will be written to this directory.";
                x = 0; y = 13; height = 1; width = 10;},
  datalabel = { class = "label"; label = "                            Paste data or enter a filepath.";
                x = 0; y = 0; height = 1; width = 10;},
  optlabel  = { class = "label"; label = "What tracking data should be applied?         Rounding";
                x = 0; y = 6; height = 1; width = 10;},
  position  = { class = "checkbox"; name = "position"; value = true; label = "Position";
                x = 0; y = 7; height = 1; width = 3;},
  clip      = { class = "checkbox"; name = "clip"; value = false; label = "Clip";
                x = 4; y = 7; height = 1; width = 2;},
  scale     = { class = "checkbox"; name = "scale"; value = true; label = "Scale";
                x = 0; y = 8; height = 1; width = 2;},
  border    = { class = "checkbox"; name = "border"; value = true; label = "Border";
                x = 2; y = 8; height = 1; width = 2;},
  shadow    = { class = "checkbox"; name = "shadow"; value = true; label = "Shadow";
                x = 4; y = 8; height = 1; width = 2;},
  rotation  = { class = "checkbox"; name = "rotation"; value = false; label = "Rotation";
                x = 0; y = 9; height = 1; width = 3;},
  posround  = { class = "intedit"; name = "posround"; value = 2; min = 0; max = 5;
                x = 7; y = 7; height = 1; width = 3;},
  sclround  = { class = "intedit"; name = "sclround"; value = 2; min = 0; max = 5;
                x = 7; y = 8; height = 1; width = 3;},
  rotround  = { class = "intedit"; name = "rotround"; value = 2; min = 0; max = 5;
                x = 7; y = 9; height = 1; width = 3;},
  wconfig   = { class = "checkbox"; name = "wconfig"; value = false; label = "Write config";
                x = 0; y = 11; height = 1; width = 4;},
  sizeratio = { class = "floatedit"; name = "sizeratio"; value = 1;
                x = 7; y = 11; height = 1; width = 3;},
  override  = { class = "checkbox"; name = "override"; value = 1;
                x = 6; y = 11; height = 1; width = 1;},
  vsfscale  = { class = "checkbox"; name = "vsfscale"; value = false; label = "VSfilter scaling";
                x = 0; y = 12; height = 1; width = 3;},
  linear    = { class = "checkbox"; name = "linear"; value = false; label = "Linear";
                x = 4; y = 12; height = 1; width = 2;},
  reverse   = { class = "checkbox"; name = "reverse"; value = false; label = "Reverse";
                x = 6; y = 12; height = 1; width = 2;},
  export    = { class = "checkbox"; name = "export"; value = false; label = "Export";
                x = 8; y = 12; height = 1; width = 2;},
  sortd     = { class = "dropdown"; name = "sortd"; hint = "Sort lines by"; value = "Default"; items = {"Default", "Time"};
                x = 5; y = 5; width = 4; height = 1;}, 
  sortlabel = { class = "label"; name = "sortlabel"; label = "      Sort Method:";
                x = 1; y = 5; width = 4; height = 1;},
}

for k,v in pairs(aegisub) do
  dpath = false
  if k == "file_name" then
    dpath = true
    require "clipboard"
    break
  end
end

if config_file == "" and dpath then config_file = aegisub.decode_path("?user/aegisub-motion.conf") end

encpre = {
x264    = '"#{encbin}" --crf 16 --tune fastdecode -i 250 --fps 23.976 --sar 1:1 --index "#{prefix}#{index}.index" --seek #{startf} --frames #{lenf} -o "#{prefix}#{output}.mp4" "#{input}"',
ffmpeg  = '"#{encbin}" -ss #{startt} -t #{lent} -sn -i "#{input}" "#{prefix}#{output}-%%05d.jpg"',
avs2yuv = 'echo FFVideoSource("#{input}",cachefile="#{prefix}#{index}.index").trim(#{startf},#{endf}).ConvertToRGB.ImageWriter("#{prefix}#{output}.",type="jpg") > "#{prefix}encode.avs"#{nl}"#{encbin}" -o NUL "#{prefix}encode.avs"#{nl}del "#{prefix}encode.avs"',}

global = {
  windows  = true,
  prefix   = "",
  encoder  = "x264",
  encbin   = "",
  gui_trim = true,
  gnupauto = false,
  autocopy = true,
  acfilter = true,
  -- encoder presets
}

global.enccom = encpre[global.encoder] or ""

header = {
  ['xscl'] = "scale_x",
  ['yscl'] = "scale_y",
  ['ali']  = "align",
  ['zrot'] = "angle",
  ['bord'] = "outline",
  ['shad'] = "shadow",
  ['_v']   = "margin_t",
  ['_l']   = "margin_l",
  ['_r']   = "margin_r",
  ['fs']   = "fontsize",
  ['fn']   = "fontname",
}

patterns = {
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
  ['fs']      = "\\fs([%d%.]+)",  
}

alltags = {
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
  ['l1c']     = "\\c&H(%x+)&",
  ['l1c2']    = "\\1c&H(%x+)&",
  ['l2c']     = "\\2c&H(%x+)&",
  ['l3c']     = "\\3c&H(%x+)&",
  ['l4c']     = "\\4c&H(%x+)&",
  ['clip']    = "\\clip%((.-)%)",
  ['iclip']   = "\\iclip%((.-)%)",
  ['be']      = "\\be([%d%.]+)",
  ['blur']    = "\\blur([%d%.]+)",
  ['fax']     = "\\fax([%-%d%.]+)",
  ['fay']     = "\\fay([%-%d%.]+)"
}

guiconf = {
  "sortd",
  "position", "clip", "posround",
  "scale", "border", "shadow", "sclround",
  "rotation", "rotround",
  "sizeratio", "override",
  "vsfscale", "linear", "reverse", "export",
}

for k,v in pairs(global) do table.insert(guiconf,k) end

function dcos(a) return math.cos(math.rad(a)) end
function dacos(a) return math.deg(math.acos(a)) end
function dsin(a) return math.sin(math.rad(a)) end
function dasin(a) return math.deg(math.asin(a)) end
function dtan(a) return math.tan(math.rad(a)) end
function datan(x,y) return math.deg(math.atan2(x,y)) end

fix = {}

fix.xpos = {
  function(sx,l,r) return sx-r end;
  function(sx,l,r) return l    end;
  function(sx,l,r) return sx/2 end;
}

fix.ypos = {
  function(sy,v) return sy-v end;
  function(sy,v) return sy/2 end;
  function(sy,v) return v    end;
}

function readconf(conf,guitab)
  local valtab = {}
  aegisub.log(5,"Opening config file: %s\n",conf)
  local cf = io.open(conf,'r')
  if cf then
    aegisub.log(5,"Reading config file...\n")
    for line in cf:lines() do
      local key, val = line:splitconf()
      aegisub.log(5,"Read: %s -> %s\n", key, tostring(val:tobool()))
      valtab[key] = val:tobool()
    end
    cf:close()
    convertfromconf(valtab,guitab)
    return true
  else
    return nil
  end
end

function convertfromconf(valtab,guitab)
  for i,v in pairs(guiconf) do
    if valtab[v] ~= nil and guitab[v] ~= nil then
      aegisub.log(5,"Set: %s <- %s\n", v, tostring(valtab[v]))
      guitab[v].value = valtab[v]
    else
      aegisub.log(5,"%s unset (nil value)\n", v)
    end
  end
end

function writeconf(conf,options)
  local cf = io.open(conf,'w+')
  local configlines = {}
  if not cf then 
    aegisub.log(0,'Config write failed! Check that %s exists and has write permission.\n',config_file)
    return nil
  end
  for i,v in pairs(guiconf) do
    if options[v] ~= nil then
      aegisub.log(5,"Write: %s:%s -> conf\n",v,tostring(options[v]))
      table.insert(configlines,string.format("%s:%s\n",v,tostring(options[v])))
    end
  end
  for i,v in ipairs(configlines) do
    cf:write(v)
  end
  cf:close()
  return true
end

function string:splitconf()
  local line = self:gsub("[\r\n]*","")
  return line:match("^(.-):(.*)$")
end

function string:tobool()
  if self == "true" then return true
  elseif self == "false" then return false
  else return self end
end

function preprocessing(sub, sel)
  for i,v in ipairs(sel) do
    local line = sub[v]
    local a = line.text:match("%{(.-)%}")
    if a then
      local length = line.end_time - line.start_time
      local function fadrep(a,b)
        a, b = tonumber(a), tonumber(b)
        local str = ""
        if a > 0 then str = str..string.format("\\alpha&HFF&\\t(%d,%d,1,\\alpha&H00&)",0,a) end -- there are a bunch of edge cases for which this won't work, I think
        if b > 0 then str = str..string.format("\\t(%d,%d,1,\\alpha&HFF&)",length-b,length) end
        return str
      end
      line.text = line.text:gsub("\\fad%(([%d]+),([%d]+)%)",fadrep)
      local function faderep(a,b,c,d,e,f,g)
        a,b,c,d,e,f,g = tonumber(a),tonumber(b),tonumber(c),tonumber(d),tonumber(e),tonumber(f),tonumber(g)
        return string.format("\\alpha&H%02X&\\t(%d,%d,1,\\alpha&H%02X&)\\t(%d,%d,1,\\alpha&H%02X&)",a,d,e,b,f,g,c)
      end
      line.text:gsub("\\fade%(([%d]+),([%d]+),([%d]+),([%-%d]+),([%-%d]+),([%-%d]+),([%-%d]+)%)",faderep)
    end
    sub[v] = line -- replace
  end
  return information(sub,sel) -- selected line numbers are the same
end

function getinfo(sub, line, num)
  for k, v in pairs(header) do
    line[k] = line.styleref[v]
    aegisub.log(5,"Line %d: %s -> %s (from header)\n", num, v, tostring(line[k]))
  end
  if line.bord then line.xbord = tonumber(line.bord); line.ybord = tonumber(line.bord); end
  if line.shad then line.xshad = tonumber(line.shad); line.yshad = tonumber(line.shad); end
  if line.text:match("\\pos%([%-%d%.]+,[%-%d%.]+%)") then -- have to check now since default pos is calculated/given by karaskel
    line.xpos, line.ypos = line.text:match("\\pos%(([%-%d%.]+),([%-%d%.]+)%)")
    line.xorg, line.yorg = line.xpos, line.ypos
    aegisub.log(5,"Line %d: pos -> (%f,%f)\n", num, line.xpos, line.ypos)
  end
  if line.text:match("\\org%(([%-%d%.]+),([%-%d%.]+)%)") then -- this should be more correctly handled now
    line.xorg, line.yorg = line.text:match("\\org%(([%-%d%.]+),([%-%d%.]+)%)")
    aegisub.log(5,"Line %d: org -> (%f,%f)\n", num, line.xorg, line.yorg)
  end
  line.trans = {}
  local a = line.text:match("%{(.-)}")
  if a then
    aegisub.log(5,"Found a comment/override block in line %d: %s\n",num,a)
    for k, v in pairs(patterns) do
      local _ = a:match(v)
      if _ then 
        line[k] = tonumber(_)
        aegisub.log(5,"Line %d: %s -> %s\n",num,k,tostring(_))
      end
    end
    if a:match("\\fn([^\\}]+)") then line.fn = a:match("\\fn([^\\}]+)") end
    local function cconv(a,b,c,d,e)
      line.clips = a
      line.clip = string.format("m %d %d l %d %d %d %d %d %d",b,c,d,c,d,e,b,e)
    end
    a:gsub("\\(i?clip)%(([%-%d]+),([%-%d]+),([%-%d]+),([%-%d]+)%)",cconv,1) -- hum
    if not line.clip then
      line.clips, line.sclip, line.clip = a:match("\\(i?clip)%(([%d]*),?(.-)%)")
    end
    if line.sclip == "" then line.sclip = false else line.sclip = tonumber(line.sclip) end
    if line.clip then 
      if line.sclip then aegisub.log(5,"Clip: \\%s(%s,%s)\n",line.clips,line.sclip,line.clip)
      else aegisub.log(5,"Clip: \\%s(%s)\n",line.clips,line.clip) end
    end -- because otherwise it crashes!
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
    if line.margin_v ~= 0 then line._v = line.margin_v end
    if line.margin_l ~= 0 then line._l = line.margin_l end
    if line.margin_r ~= 0 then line._r = line.margin_r end
  else
    aegisub.log(5,"No comment/override block found in line %d\n",num)
  end
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
  accd.vn = getvideoname(sub):gsub("[A-Z]:\\",""):gsub(".-[^\\]\\","")
  accd.lines = {}
  accd.endframe = aegisub.frame_from_ms(sub[sel[1]].end_time) -- get the end frame of the first selected line
  accd.startframe = aegisub.frame_from_ms(sub[sel[1]].start_time) -- get the start frame of the first selected line
  accd.poserrs, accd.alignerrs = {}, {}
  local numlines = #sel
  for i, v in pairs(sel) do -- burning cpu cycles like they were no thing
    local opline = sub[v] -- these are different.
    opline.num = v -- for inserting lines later
    karaskel.preproc_line(sub, accd.meta, accd.styles, opline) -- get linewidth/height and margins
    if not opline.effect then opline.effect = "" end
    getinfo(sub, opline, v-strt)
    opline.styleref.fontname = opline.fn
    opline.styleref.fontsize = opline.fs
    local ofsx,ofsy = opline.styleref.scale_x,opline.styleref.scale_y
    opline.styleref.scale_y = 100
    opline.styleref.scale_x = 100
    opline.width, opline.height, opline.descent, opline.extlead = aegisub.text_extents(opline.styleref,opline.text_stripped)
    opline.styleref.scale_x,opline.styleref.scale_y = ofsx,ofsy
    if opline.margin_v ~= 0 then opline._v = opline.margin_v end
    if opline.margin_l ~= 0 then opline._l = opline.margin_l end
    if opline.margin_r ~= 0 then opline._r = opline.margin_r end
    opline.startframe, opline.endframe = aegisub.frame_from_ms(opline.start_time), aegisub.frame_from_ms(opline.end_time)
    if opline.comment then opline.is_comment = true else opline.is_comment = false end
    if not opline.xpos then
      aegisub.log(5,"Touching little boys\n")
      opline.xpos = fix.xpos[opline.ali%3+1](accd.meta.res_x,opline._l,opline._r)
      opline.ypos = fix.ypos[math.ceil(opline.ali/3)](accd.meta.res_y,opline._v)
      aegisub.log(5,"Line %d: pos -> (%f,%f)\n", opline.num, opline.xpos, opline.ypos)
    end
    if opline.xorg then
      local xd = opline.xpos - opline.xorg
      local yd = opline.ypos - opline.yorg
      local r = math.sqrt(xd^2+yd^2)
      local alpha = datan(yd,xd)
      opline.xpos = opline.xorg + r*dcos(alpha-opline.zrot)
      opline.ypos = opline.yorg + r*dsin(alpha-opline.zrot)
      opline.text = opline.text:gsub("\\org%(([%-%d%.]+),([%-%d%.]+)%)","")
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
  end
  local length = #accd.lines
  local copy = {}
  for i,v in ipairs(accd.lines) do
    copy[length-i+1] = v
  end
  accd.lines = copy
  accd.totframes = accd.endframe - accd.startframe
  assert(#accd.lines>0,"You have to select at least one line that is longer than one frame long.") -- pro error checking
  printmem("End of preproc loop")
  return accd
end

function init_input(sub,sel) -- THIS IS PROPRIETARY CODE YOU CANNOT LOOK AT IT
  aegisub.progress.title("Selecting Gerbils")
  local accd = preprocessing(sub,sel)
  for k,v in pairs(global) do
    gui.main[k] = {}
  end
  local cf
  if not (config_file:match("^[A-Z]:\\") or config_file:match("^/")) and dpath then
    cf = io.open(aegisub.decode_path("?script/"..config_file))
    if not cf then
      cf = aegisub.decode_path("?user/"..config_file)
    else
      cf:close()
      cf = aegisub.decode_path("?script/"..config_file)
    end
  else
    cf = config_file
  end
  if not readconf(cf,gui.main) then aegisub.log(0,"Failed to read config!") end
  for k,v in pairs(global) do
    global[k] = gui.main[k].value
    gui.main[k] = nil -- set to nil so dialog.display doesn't throw a hissy fit
  end
  if dpath and global.autocopy then
    local paste = clipboard.get()
    if global.acfilter then
      if paste:match("^Adobe After Effects 6.0 Keyframe Data") then
        gui.main.linespath.value = paste
      end
    else
      gui.main.linespath.value = paste
    end
  end
  gui.main.pref.value = global.prefix
  printmem("GUI startup")
  local button, config = aegisub.dialog.display(gui.main, {"Go","Abort","Export"})
  if button == "Go" then
    if config.linespath == "" then config.linespath = false end
    if config.reverse then
      aegisub.progress.title("slibreG gnicniM") -- BECAUSE ITS FUNNY GEDDIT
    else
      aegisub.progress.title("Mincing Gerbils")
    end
    if config.wconfig then
      for k,v in pairs(global) do
        config[k] = v
      end
      writeconf(cf,config)
    end
    printmem("Go")
    local newsel = frame_by_frame(sub,accd,config)
    if munch(sub,newsel) then
      newsel = {}
      for x = 1,#sub do
        if tostring(sub[x].effect):match("^aa%-mou") then
          table.insert(newsel,x)
        end
      end
    end
    aegisub.progress.title("Reformatting Gerbils")
    cleanup(sub,newsel,config)
  elseif button == "Export" then
    export(accd,parse_input(config.linespath,accd.meta.res_x,accd.meta.res_y,config),config)
  else
    aegisub.progress.task("ABORT")
    if dpath then aegisub.cancel() end
  end
  aegisub.set_undo_point("Motion Data")
  printmem("Closing")
end

function parse_input(input,shx,shy,opts)
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
  local xmult,ymult
  if opts.override then
    xmult, ymult = opts.sizeratio, opts.sizeratio
  else
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
    xmult = shx/tonumber(sw)
    ymult = shy/tonumber(sh)
  end
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
        if not mocha.xmax then mocha.xmax = tonumber(val[2]) elseif tonumber(val[2]) > mocha.xmax then mocha.xmax = tonumber(val[2]) end
        if not mocha.xmin then mocha.xmin = tonumber(val[2]) elseif tonumber(val[2]) < mocha.xmin then mocha.xmin = tonumber(val[2]) end
        table.insert(mocha.ypos,tonumber(val[3])*ymult)
        if not mocha.ymax then mocha.ymax = tonumber(val[3]) elseif tonumber(val[3]) > mocha.ymax then mocha.ymax = tonumber(val[3]) end
        if not mocha.ymin then mocha.ymin = tonumber(val[3]) elseif tonumber(val[3]) < mocha.ymin then mocha.ymin = tonumber(val[3]) end
      end
    elseif sect <= 3 and sect >= 2 then
      if valu:match("%d") then
        val = valu:split("\t")
        table.insert(mocha.xscl,tonumber(val[2]))
        if not mocha.xsmax then mocha.xsmax = tonumber(val[2]) elseif tonumber(val[2]) > mocha.xsmax then mocha.xsmax = tonumber(val[2]) end
        if not mocha.xsmin then mocha.xsmin = tonumber(val[2]) elseif tonumber(val[2]) < mocha.xsmin then mocha.xsmin = tonumber(val[2]) end
        table.insert(mocha.yscl,tonumber(val[3]))
        if not mocha.ysmax then mocha.ysmax = tonumber(val[3]) elseif tonumber(val[3]) > mocha.ysmax then mocha.ysmax = tonumber(val[3]) end
        if not mocha.ysmin then mocha.ysmin = tonumber(val[3]) elseif tonumber(val[3]) < mocha.ysmin then mocha.ysmin = tonumber(val[3]) end
      end
    elseif sect <= 7 and sect >= 4 then
      if valu:match("%d") then
        val = valu:split("\t")
        table.insert(mocha.zrot,-tonumber(val[2]))
        if not mocha.rmax then mocha.rmax = -tonumber(val[2]) elseif -tonumber(val[2]) > mocha.rmax then mocha.rmax = -tonumber(val[2]) end
        if not mocha.rmin then mocha.rmin = -tonumber(val[2]) elseif -tonumber(val[2]) < mocha.rmin then mocha.rmin = -tonumber(val[2]) end
      end
    end
  end
  mocha.flength = #mocha.xpos
  assert(mocha.flength == #mocha.ypos and mocha.flength == #mocha.xscl and mocha.flength == #mocha.yscl and mocha.flength == #mocha.zrot,"The data is not internally equal length.") -- make sure all of the elements are the same length (because I don't trust my own code).
  printmem("End of input parsing")
  return mocha -- hurr durr
end

function frame_by_frame(sub,accd,opts)
  printmem("Start of main loop")
  local mocha
  local clipa
  if opts.linespath then
    mocha = parse_input(opts.linespath,accd.meta.res_x,accd.meta.res_y,opts)
    assert(accd.totframes==mocha.flength,string.format("Number of frames selected (%d) does not match parsed line tracking data length (%d).",accd.totframes,mocha.flength))
  end
  if opts.export then export(accd,mocha,opts) end
  mocha.s = 1
  if opts.reverse then mocha.s = mocha.flength end
  for k,v in ipairs(accd.lines) do -- comment lines that were commented in the thingy
    local derp = sub[v.num]
    derp.comment = true
    --derp.effect = "aa-mo2"..derp.effect
    sub[v.num] = derp
    if not v.is_comment then v.comment = false end
  end
  local _ = nil
  local newlines = {} -- table to stick indicies of tracked lines into for cleanup.
  if not opts.scale then
    for k,d in ipairs(mocha.xscl) do
      mocha.xscl[k] = 100 -- old method was wrong and didn't work.
      mocha.yscl[k] = 100 -- so that yscl is changed too. 
    end
  end
  if not opts.rotation then
    for k,d in ipairs(mocha.zrot) do
      mocha.zrot[k] = 0
    end
  end
  local operations, eraser = {}, {} -- create a table and put the necessary functions into it, which will save a lot of if operations in the inner loop. This was the most elegant solution I came up with.
  if opts.position then
    if opts.clip then
      table.insert(operations,posiclip)
      table.insert(eraser,"\\i?clip%b()")
    else
      table.insert(operations,possify)
    end
    table.insert(eraser,"\\\pos%([%-%d%.]+,[%-%d%.]+%)") -- \\\ because I DON'T FUCKING KNOW OKAY THAT'S JUST THE WAY IT WORKS
  end
  if opts.scale then
    if opts.vsfscale then
      table.insert(operations,VScalify)
    else
      table.insert(operations,scalify)
    end
    table.insert(eraser,"\\fscx[%d%.]+")
    table.insert(eraser,"\\fscy[%d%.]+")
    if opts.border then
      table.insert(operations,bordicate)
      table.insert(eraser,"\\xbord[%d%.]+")
      table.insert(eraser,"\\ybord[%d%.]+")
      table.insert(eraser,"\\bord[%d%.]+")
    end
    if opts.shadow then
      table.insert(operations,shadinate)
      table.insert(eraser,"\\xshad[%-%d%.]+")
      table.insert(eraser,"\\yshad[%-%d%.]+")
      table.insert(eraser,"\\shad[%-%d%.]+")
    end
  end
  if opts.vsfscale then
    opts.sclround = 2
  end
  if opts.rotation then
    table.insert(eraser,"\\org%([%-%d%.]+,[%-%d%.]+%)")
    table.insert(operations,rotate)
    table.insert(eraser,"\\frz[%-%d%.]+")
  end
  printmem("End of table insertion")
  for i,v in ipairs(accd.lines) do
    printmem("Outer loop")
    local rstartf = v.startframe - accd.startframe + 1 -- start frame of line relative to start frame of tracked data
    local rendf = v.endframe - accd.startframe -- end frame of line relative to start frame of tracked data
    local maths, mathsanswer = nil, nil -- create references without allocation? idk how this works.
    v.effect = "aa-mou"..v.effect
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
    if opts.rotation then
      v.zrotd = mocha.zrot[rstartf] - v.zrot -- idr there was something silly about this
    end
    if v.xpos and opts.position then
      v.xdiff, v.ydiff = mocha.xpos[rstartf] - v.xpos, mocha.ypos[rstartf] - v.ypos
    end
    for ie, ei in pairs(eraser) do -- have to do it before inserting our new values (also before setting the orgline)
      v.text = v.text:gsub(ei,"")
    end
    local orgtext = v.text -- tables are passed as references.
    if opts.position and not v.xpos then -- I don't think I need this any more
      aegisub.log(1,"Line %d is being skipped because it is missing a \\pos() tag and you said to track position. Moron.",v.num) -- yeah that should do it.
    else
      if opts.reverse then -- reverse order
        if opts.linear then
          if not v.is_comment then
            v.ratx, v.raty = mocha.xscl[rendf]/mocha.xscl[rstartf],mocha.yscl[rendf]/mocha.yscl[rstartf]
            local tag = "{"
            local trans = string.format("\\t(%d,%d,",maths,mathsanswer)
            if opts.position then
              tag = tag..string.format("\\move(%g,%g,%g,%g,%d,%d)",mocha.xpos[rendf]-v.xdiff*v.ratx,mocha.ypos[rendf]-v.ydiff*v.raty,v.xpos,v.ypos,maths,mathsanswer)
            end
            local pre, rtrans = linearize(v,mocha,opts,rstartf,rendf)
            if pre ~= "" then
              tag = tag..pre..trans..rtrans..")}"..string.char(6)
            else
              tag = tag.."}"..string.char(6)
            end
            v.text = tag..v.text
          end
          sub[v.num] = v -- yep
        else
          rstartf, rendf = rendf, rstartf -- un-reverse them
          for x = rstartf,rendf do
            printmem("Inner loop")
            aegisub.progress.title(string.format("Processing frame %g/%g",x-rstartf+1,rendf-rstartf+1))
            aegisub.progress.set((x-rstartf)/(rendf-rstartf)*100)
            if aegisub.progress.is_cancelled() then error("User cancelled") end
            local iter = rendf-x+1 -- hm
            v.start_time = aegisub.ms_from_frame(accd.startframe+iter-1)
            v.end_time = aegisub.ms_from_frame(accd.startframe+iter)
            if not v.is_comment then -- don't touch commented lines.
              local tag = "{"
              v.ratx = mocha.xscl[iter]/mocha.xscl[rendf] -- DIVISION IS SLOW
              v.raty = mocha.yscl[iter]/mocha.yscl[rendf]
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
            end
            sub.insert(v.num+1,v)
            v.text = orgtext
          end
        end
      else -- normal order
        if opts.linear then
          if not v.is_comment then
            v.ratx, v.raty = mocha.xscl[rendf]/mocha.xscl[rstartf],mocha.yscl[rendf]/mocha.yscl[rstartf]
            local tag = "{"
            local trans = string.format("\\t(%d,%d,",maths,mathsanswer)
            if opts.position then
              tag = tag..string.format("\\move(%g,%g,%g,%g,%d,%d)",v.xpos,v.ypos,mocha.xpos[rendf]-v.xdiff*v.ratx,mocha.ypos[rendf]-v.ydiff*v.raty,maths,mathsanswer)
            end
            local pre, rtrans = linearize(v,mocha,opts,rstartf,rendf)
            if pre ~= "" then
              tag = tag..pre..trans..rtrans..")}"..string.char(6)
            else
              tag = tag.."}"..string.char(6)
            end
            v.text = tag..v.text
          end
          sub[v.num] = v -- yep
        else
          for x = rstartf,rendf do
            printmem("Inner loop")
            aegisub.progress.title(string.format("Processing frame %g/%g",x-rstartf+1,rendf-rstartf+1))
            aegisub.progress.set((x-rstartf)/(rendf-rstartf)*100)
            if aegisub.progress.is_cancelled() then error("User cancelled") end -- probably should have put this in here a long time ago
            v.start_time = aegisub.ms_from_frame(accd.startframe+x-1)
            v.end_time = aegisub.ms_from_frame(accd.startframe+x)
            if not v.is_comment then
              local tag = "{"
              v.ratx = mocha.xscl[x]/mocha.xscl[rstartf] -- DIVISION IS SLOW
              v.raty = mocha.yscl[x]/mocha.yscl[rstartf]
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
            end
            sub.insert(v.num+x-rstartf+1,v)
            v.text = orgtext
          end
        end
      end
    end
  end
  for x = 1,#sub do
    if tostring(sub[x].effect):match("^aa%-mou") then
      aegisub.log(5,"I choose you, %d!\n",x)
      table.insert(newlines,x) -- seems to work as intended
    end
  end
  return newlines -- yeah mang
end

function linearize(line,mocha,opts,rstartf,rendf)
  local pre,trans = "",""
  if opts.scale then
    pre = pre..string.format("\\fscx%g\\fscy%g",round(line.xscl*line.ratx,opts.sclround),round(line.yscl*line.raty,opts.sclround))
    trans = trans..string.format("\\fscx%g\\fscy%g",line.xscl,line.yscl)
    if opts.border then
      if line.xbord == line.ybord then
        pre = pre..string.format("\\bord%g",round(line.xbord*line.ratx,opts.sclround))
        trans = trans..string.format("\\bord%g",line.xbord)
      else
        pre = pre..string.format("\\xbord%g\\ybord%g",round(line.xbord*line.ratx,opts.sclround),round(line.ybord*line.raty,opts.sclround))
        trans = trans..string.format("\\xbord%g\\ybord%g",line.xbord,line.ybord)
      end
    end
    if opts.shadow then
      if line.xbord == line.ybord then
        pre = pre..string.format("\\shad%g",round(line.xshad*line.ratx,opts.sclround))
        trans = trans..string.format("\\shad%g",line.xshad)
      else
        pre = pre..string.format("\\xshad%g\\yshad%g",round(line.xshad*line.ratx,opts.sclround),round(line.yshad*line.raty,opts.sclround))
        trans = trans..string.format("\\xshad%g\\yshad%g",line.xshad,line.yshad)
      end
    end
  end
  if opts.rotation then
    pre = pre..string.format("\\frz%g",round(mocha.zrot[rendf]-line.zrotd,opts.sclround)) -- not being able to move org might be a large issue
    trans = trans..string.format("\\frz%g",mocha.zrot)
  end
  if opts.reverse then
    return pre, trans
  else
    return trans, pre
  end
end

function possify(line,mocha,opts,iter)
  local xpos = mocha.xpos[iter]-(line.xdiff*line.ratx)
  local ypos = mocha.ypos[iter]-(line.ydiff*line.raty)
  local xd = xpos - mocha.xpos[iter]
  local yd = ypos - mocha.ypos[iter]
  local r = math.sqrt(xd^2+yd^2)
  local alpha = datan(yd,xd) -- this should be a constant---move its calculation outside the inner loop, perhaps?
  xpos = mocha.xpos[iter] + r*dcos(alpha-mocha.zrot[iter]+mocha.zrot[mocha.s])
  ypos = mocha.ypos[iter] + r*dsin(alpha-mocha.zrot[iter]+mocha.zrot[mocha.s])
  aegisub.log(5,"Position: (%f,%f) -> (%f,%f)\n",line.xpos,line.ypos,xpos,ypos)
  local nf = string.format("%%.%df",opts.posround) -- new method of number formatting!
  return "\\pos("..string.format(nf,xpos)..","..string.format(nf,ypos)..")"
end

function posiclip(line,mocha,opts,iter)
  local xpos = mocha.xpos[iter]-(line.xdiff*line.ratx)
  local ypos = mocha.ypos[iter]-(line.ydiff*line.raty)
  local xd = xpos - mocha.xpos[iter]
  local yd = ypos - mocha.ypos[iter]
  local r = math.sqrt(xd^2+yd^2)
  local alpha = datan(yd,xd)
  xpos = mocha.xpos[iter] + r*dcos(alpha-mocha.zrot[iter]+mocha.zrot[mocha.s])
  ypos = mocha.ypos[iter] + r*dsin(alpha-mocha.zrot[iter]+mocha.zrot[mocha.s])
  aegisub.log(5,"Position: (%f,%f) -> (%f,%f)\n",line.xpos,line.ypos,xpos,ypos)
  local nf = string.format("%%.%df",opts.posround) -- new method of number formatting!
  local clip = ""
  if line.clip then
    local newvals = {}
    local newclip = line.clip
    local it = 0
    local function xy(x,y)
      local xo,yo = x,y
      x = (tonumber(x) - line.xpos)*line.xscl*line.ratx/100
      y = (tonumber(y) - line.ypos)*line.yscl*line.raty/100
      local pr = math.sqrt(x^2+y^2)
      local theta = datan(y,x)
      x = xpos + pr*dcos(theta-mocha.zrot[iter]+mocha.zrot[mocha.s])
      y = ypos + pr*dsin(theta-mocha.zrot[iter]+mocha.zrot[mocha.s])
      aegisub.log(5,"Clip: %d %d -> %d %d\n",xo,yo,x,y)
      if line.sclip then 
        x = x*1024/(2^(line.sclip-1))
        y = y*1024/(2^(line.sclip-1))
      end
      table.insert(newvals,round(x).." "..round(y))
      it = it+1
      return string.char(1)
    end
    newclip = newclip:gsub("([%.%d%-]+) ([%.%d%-]+)",xy)
    local i = 0
    local function ret(sub)
      i = i+1
      return newvals[i]
    end
    newclip = newclip:gsub(string.char(1),ret)
    if line.sclip then 
      clip = string.format("\\%s(11,%s)",line.clips,newclip)
    else
      clip = string.format("\\%s(%s)",line.clips,newclip)
    end
  end
  return "\\pos("..string.format(nf,xpos)..","..string.format(nf,ypos)..")"..clip
end

function transformate(line,trans)
  local t_s = trans[1] - line.time_delta -- well, that was easy
  local t_e = trans[2] - line.time_delta
  aegisub.log(5,"Transform: %d,%d -> %d,%d\n",trans[1],trans[2],t_s,t_e)
  return line.text:gsub("\\t%b()","\\"..string.char(1)..string.format("t(%d,%d,%g,%s)",t_s,t_e,trans[3],trans[4]),1)
end

function scalify(line,mocha,opts)
  local xscl = line.xscl*line.ratx
  aegisub.log(5,"X Scale: %f -> %f\n",line.xscl,xscl)
  local yscl = line.yscl*line.raty
  aegisub.log(5,"Y Scale: %f -> %f\n",line.yscl,yscl)
  return string.format("\\fscx%g\\fscy%g",round(xscl,opts.sclround),round(yscl,opts.sclround))
end

function bordicate(line,mocha,opts)
  local xbord = line.xbord*round(line.ratx,opts.sclround) -- round beforehand to minimize random float errors
  local ybord = line.ybord*round(line.raty,opts.sclround) -- or maybe that's rly fucking dumb? idklol
  if xbord == ybord then
    aegisub.log(5,"Border: %f -> %f\n",line.xbord,xbord)
    return string.format("\\bord%g",round(xbord,opts.sclround))
  else
    aegisub.log(5,"XBorder: %f -> %f\n",line.xbord,xbord)
    aegisub.log(5,"YBorder: %f -> %f\n",line.ybord,ybord)
    return string.format("\\xbord%g\\ybord%g",round(xbord,opts.sclround),round(ybord,opts.sclround))
  end
end

function shadinate(line,mocha,opts)
  local xshad = line.xshad*round(line.ratx,opts.sclround) -- scale shadow the same way as everything else
  local yshad = line.yshad*round(line.raty,opts.sclround) -- hope it turns out as desired
  if xshad == yshad then
    aegisub.log(5,"Shadow: %f -> %f\n",line.xshad,xshad)
    return string.format("\\shad%g",round(xshad,opts.sclround))
  else
    aegisub.log(5,"XShadow: %f -> %f\n",line.xshad,xshad)
    aegisub.log(5,"YShadow: %f -> %f\n",line.yshad,yshad)
    return string.format("\\xshad%g\\yshad%g",round(xshad,opts.sclround),round(yshad,opts.sclround))
  end
end

function VScalify(line,mocha,opts)
  local xscl = round(line.xscl*line.ratx,2)
  local yscl = round(line.yscl*line.raty,2)
  local xlowend, xhighend, xdecimal = math.floor(xscl),math.ceil(xscl),xscl%1*100
  local xstart, xend = -xdecimal, 100-xdecimal
  local ylowend, yhighend, ydecimal = math.floor(yscl),math.ceil(yscl),yscl%1*100
  local ystart, yend = -ydecimal, 100-ydecimal
  aegisub.log(5,"X Scale: %f -> %f\n",line.xscl,xscl)
  aegisub.log(5,"X Scale: %f -> %f\n",line.xscl,xscl)
  return string.format("\\fscx%d\\t(%d,%d,\\fscx%d)\\fscy%d\\t(%d,%d,\\fscy%d)",xlowend,xstart,xend,xhighend,ylowend,ystart,yend,yhighend)
end

function rotate(line,mocha,opts,iter)
  local zrot = mocha.zrot[iter]-line.zrotd
  aegisub.log(5,"ZRotation: -> %f\n",zrot)
  return string.format("\\frz%g",round(zrot,opts.rotround)) -- copypasta
end

function munch(sub,sel)
  local changed = false
  for i,v in ipairs(sel) do 
    local num = sel[#sel-i+1]
    local l1 = sub[num-1]
    local l2 = sub[num]
    if l1.text == l2.text then
      l1.end_time = l2.end_time
      sub[num-1]=l1
      sub.delete(num)
      changed = true
    end
  end
  return changed
end

function cleanup(sub, sel, opts) -- make into its own macro eventually.
  opts = opts or {}
  local linediff
  local function cleantrans(cont) -- internal function because that's the only way to pass the line difference to it
    local t_s, t_e, ex, eff = cont:sub(2,-2):match("([%-%d]+),([%-%d]+),([%d%.]*),?(.+)")
    if tonumber(t_e) <= 0 or tonumber(t_e) <= tonumber(t_s) then return string.format("%s",eff) end -- if the end time is less than or equal to zero, the transformation has finished. Replace it with only its contents.
    if tonumber(t_s) > linediff then return "" end -- if the start time is greater than the length of the line, the transform has not yet started, and can be removed from the line.
    if tonumber(ex) == 1 or ex == "" then return string.format("\\t(%s,%s,%s)",t_s,t_e,eff) end -- if the exponential factor is equal to 1 or isn't there, remove it (just makes it look cleaner)
    return string.format("\\t(%s,%s,%s,%s)",t_s,t_e,ex,eff) -- otherwise, return an untouched transform.
  end
  local ns = {}
  for i, v in ipairs(sel) do
    aegisub.progress.title(string.format("Castrating gerbils: %d/%d",i,#sel))
    local lnum = sel[#sel-i+1]
    local line = sub[lnum] -- iterate backwards (makes line deletion sane)
    linediff = line.end_time - line.start_time
    line.text = line.text:gsub("}"..string.char(6).."{","") -- merge sequential override blocks if they are marked as being the ones we wrote
    line.text = line.text:gsub(string.char(6),"") -- remove superfluous marker characters for when there is no override block at the beginning of the original line
    line.text = line.text:gsub("\\t(%b())",cleantrans) -- clean up transformations (remove transformations that have completed)
    line.text = line.text:gsub("{}","") -- I think this is irrelevant. But whatever.
    for a in line.text:gmatch("{(.-)}") do
      aegisub.progress.set(math.random(100)) -- professional progress bars
      local trans = {}
      repeat -- have to cut out transformations so their contents don't get detected as dups
        if aegisub.progress.is_cancelled() then error("User cancelled") end
        local low, high, trabs = a:find("(\\t%b())")
        if low then
          aegisub.log(5,"Cleanup: %s found\n",trabs)
          a = a:gsub("\\t%b()",string.char(3),1) -- nngah
          table.insert(trans,trabs)
        end
      until not low 
      for k,v in pairs(alltags) do
        local _, num = a:gsub(v,"")
        --aegisub.log(5,"v: %s, num: %s, a: %s\n",v,num,a)
        a = a:gsub(v,"",num-1)
      end
      for i,v in ipairs(trans) do
        a = a:gsub(string.char(3),v,1)
      end
      line.text = line.text:gsub("{.-}",string.char(1)..a..string.char(2),1) -- I think...
    end
    line.text = line.text:gsub(string.char(1),"{")
    line.text = line.text:gsub(string.char(2),"}")
    line.effect = line.effect:gsub("aa%-mou","",1)
    sub[lnum] = line
  end
  if opts.sortd ~= "Default" then
    sel = dialog_sort(sub, sel, opts.sortd)
  end
end

function dialog_sort(sub, sel, sor)
  local function compare(a,b)
    if a.key == b.key then
      return a.num < b.num -- solve the disorganized sort problem.
    else
      return a.key < b.key
    end
  end -- local because why not?
  local sortF = ({
    ['Time']   = function(l,n) return { key = l.start_time, num = n, data = l } end;
    --[[ These are pretty pointless since they should all end up in the same order as "Default"
    ['Actor']  = function(l,n) return { key = l.actor,  num = n, data = l } end;
    ['Effect'] = function(l,n) return { key = l.effect, num = n, data = l } end;
    ['Style']  = function(l,n) return { key = l.style,  num = n, data = l } end;
    ['Layer']  = function(l,n) return { key = l.layer,  num = n, data = l } end; 
    --]]
  })[sor] -- thanks, tophf
  local lines = {}
  for i,v in ipairs(sel) do
    if aegisub.progress.is_cancelled() then error("User cancelled") end -- should probably put these in every loop
    local line = sub[v]
    table.insert(lines,sortF(line,v))
  end
  local strt = sel[1] -- not strictly necessary
  table.sort(lines, compare)
  for i, v in ipairs(sel) do
    if aegisub.progress.is_cancelled() then error("User cancelled") end
    sub.delete(sel[#sel-i+1]) -- BALEET (in reverse because they are not necessarily contiguous)
  end
  sel = {}
  for i, v in ipairs(lines) do
    if aegisub.progress.is_cancelled() then error("User cancelled") end
    aegisub.progress.title(string.format("Sorting gerbils: %d/%d",i,#lines))
    aegisub.progress.set(i/#lines*100) 
    aegisub.log(5,"Key: "..v.key..'\n')
    table.insert(sel,strt+i-1)
    sub.insert(strt+i-1,v.data) -- not sure this is the best place to do this but owell
  end
  return sel
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
  local l = aegisub.video_size() and true or false -- and forces boolean conversion?
  if dpath then
    if l then
      return l
    else
      return l,"Validation failed: you don't have a video loaded."
    end
  else
    return l
  end
end

aegisub.register_macro("Motion Data - Apply", "Applies properly formatted motion tracking data to selected subtitles.", init_input, isvideo)

function export(accd,mocha,opts)
  local fnames = {}
  if opts.position then
    fnames[1] = "%s X-Y %d-%d.txt"
    fnames[2] = "%s T-X %d-%d.txt"
    fnames[3] = "%s T-Y %d-%d.txt"
  end
  if opts.scale then
    fnames[4] = "%s T-sclX %d-%d.txt"
    fnames[5] = "%s T-sclY %d-%d.txt"
  end
  if opts.rotation then
    fnames[6] = "%s T-rot %d-%d.txt"
  end
  fnames[7] = "%s gnuplot-command %d-%d.txt"
  -- open files
  local eff = accd.lines[1].effect:gsub("^aa-mou","",1)
  if eff == "" then eff = nil end
  local name = eff or accd.lines[1].actor or accd.vn or "Untitled"
  for k,v in pairs(fnames) do
    local it = 0
    repeat
      if aegisub.progress.is_cancelled() then error("User cancelled") end
      it = it + 1
      local n = string.format(v,name,accd.startframe,it)
      local f = io.open(global.prefix..n,'r')
      if f then f:close(); f = false else f = true; fnames[k] = n end -- uhhhhhhh...
    until f == true -- this is probably the worst possible way of doing this imaginable
  end
  local fhandle = {}
  local len = (aegisub.ms_from_frame(accd.endframe) - aegisub.ms_from_frame(accd.startframe))/10
  local bigstring = {}
  if opts.position then
    table.insert(bigstring,string.format([=[set terminal png small transparent truecolor size %d,%d; set output '%s.png']=]..'\n',accd.meta.res_x+70,accd.meta.res_y+80,global.prefix..fnames[1]:sub(0,-5)))
    table.insert(bigstring,string.format([=[set title 'Plot of X vs Y']=]..'\n'))
    table.insert(bigstring,string.format([=[unset xtics; set x2tics out mirror; set mx2tics 5; set x2label 'X Position (Pixels)'; set xrange [0:%d]]=]..'\n',accd.meta.res_x))
    table.insert(bigstring,string.format([=[set ytics out; set mytics 5; set ylabel 'Y Position (Pixels)'; set yrange [0:%d] reverse]=]..'\n',accd.meta.res_y))
    table.insert(bigstring,string.format([=[set grid x2tics mx2tics mytics ytics; stats '%s' using 1:2 name 'XvYstat']=]..'\n',global.prefix..fnames[1]))
    table.insert(bigstring,string.format([=[f(x) = m*x + b; fit f(x) '%s' using 1:2 via m,b]=]..'\n',global.prefix..fnames[1]))
    table.insert(bigstring,string.format([=[if (b >= 0) slope = sprintf('y(x) = %%.3fx + %%.3f : R^2: %%.3f',m,b,XvYstat_correlation**2); else slope = sprintf('y(x) = %%.3fx - %%.3f : R^2: %%.3f',m,0-b,XvYstat_correlation**2)]=]..'\n'))
    table.insert(bigstring,string.format([=[plot '%s' using 1:2 notitle with points, f(x) title slope with lines]=]..'\n',global.prefix..fnames[1]))

    table.insert(bigstring,string.format('\n'..[=[set terminal png small transparent truecolor size %d,%d; set output '%s.png']=]..'\n',round(len*2+70,0),accd.meta.res_x+80,global.prefix..fnames[2]:sub(0,-5)))
    table.insert(bigstring,string.format([=[set title 'Plot of T vs X'; unset x2label]=]..'\n'))
    table.insert(bigstring,string.format([=[unset x2tics; unset mx2tics; set xtics out mirror; set mxtics 5; set xlabel 'Time (centiseconds)'; set xrange [0:%d]]=]..'\n',round(len,0)))
    table.insert(bigstring,string.format([=[set ytics out; set mytics 5; set ylabel 'X Position (Pixels)'; set yrange [0:%d] reverse]=]..'\n',accd.meta.res_x))
    table.insert(bigstring,string.format([=[set grid xtics mxtics ytics mytics; stats '%s' using 1:2 name 'TvXstat']=]..'\n',global.prefix..fnames[2]))
    table.insert(bigstring,string.format([=[f(x) = m*x + b; fit f(x) '%s' using 1:2 via m,b]=]..'\n',global.prefix..fnames[2]))
    table.insert(bigstring,string.format([=[if (b >= 0) slope = sprintf('Equation: x(t) = %%.3ft + %%.3f : R^2: %%.3f',m,b,TvXstat_correlation**2); else slope = sprintf('Equation: x(t) = %%.3ft - %%.3f : R^2: %%.3f',m,0-b,TvXstat_correlation**2)]=]..'\n'))
    table.insert(bigstring,string.format([=[plot '%s' using 1:2 notitle with points, f(x) title slope with lines]=]..'\n',global.prefix..fnames[2]))

    table.insert(bigstring,string.format('\n'..[=[set terminal png small transparent truecolor size %d,%d; set output '%s.png']=]..'\n',round(len*2+70,0),accd.meta.res_x+80,global.prefix..fnames[3]:sub(0,-5)))
    table.insert(bigstring,string.format([=[set title 'Plot of T vs Y'; unset x2label]=]..'\n'))
    table.insert(bigstring,string.format([=[unset x2tics; unset mx2tics; set xtics out mirror; set mxtics 5; set xlabel 'Time (centiseconds)'; set xrange [0:%d]]=]..'\n',round(len,0)))
    table.insert(bigstring,string.format([=[set ytics out; set mytics 5; set ylabel 'Y Position (Pixels)'; set yrange [0:%d] reverse]=]..'\n',accd.meta.res_y))
    table.insert(bigstring,string.format([=[set grid xtics mxtics ytics mytics; stats '%s' using 1:2 name 'TvYstat']=]..'\n',global.prefix..fnames[3]))
    table.insert(bigstring,string.format([=[f(x) = m*x + b; fit f(x) '%s' using 1:2 via m,b]=]..'\n',global.prefix..fnames[3]))
    table.insert(bigstring,string.format([=[if (b >= 0) slope = sprintf('Equation: y(t) = %%.3ft + %%.3f : R^2: %%.3f',m,b,TvYstat_correlation**2); else slope = sprintf('Equation: y(t) = %%.3ft - %%.3f : R^2: %%.3f',m,0-b,TvYstat_correlation**2)]=]..'\n'))
    table.insert(bigstring,string.format([=[plot '%s' using 1:2 notitle with points, f(x) title slope with lines]=]..'\n',global.prefix..fnames[3]))
  end
  if opts.scale then
    table.insert(bigstring,string.format('\n'..[=[set terminal png small transparent truecolor size %d,%d; set output '%s.png']=]..'\n',round(len*2+70,0),600,global.prefix..fnames[4]:sub(0,-5)))
    table.insert(bigstring,string.format([=[set title 'Plot of T vs sclX'; unset x2label]=]..'\n'))
    table.insert(bigstring,string.format([=[unset x2tics; unset mx2tics; set xtics out mirror; set mxtics 5; set xlabel 'Time (centiseconds)'; set xrange [0:%d]]=]..'\n',round(len,0)))
    table.insert(bigstring,string.format([=[set ytics out; set mytics 5; set ylabel 'X Scale (Percent)'; set yrange [0:*] reverse]=]..'\n'))
    table.insert(bigstring,string.format([=[set grid xtics mxtics ytics mytics; stats '%s' using 1:2 name 'TvSXstat']=]..'\n',global.prefix..fnames[4]))
    table.insert(bigstring,string.format([=[f(x) = m*x + b; fit f(x) '%s' using 1:2 via m,b]=]..'\n',global.prefix..fnames[4]))
    table.insert(bigstring,string.format([=[if (b >= 0) slope = sprintf('Equation: sclx(t) = %%.3ft + %%.3f : R^2: %%.3f',m,b,TvSXstat_correlation**2); else slope = sprintf('Equation: sclx(t) = %%.3ft - %%.3f : R^2: %%.3f',m,0-b,TvSXstat_correlation**2)]=]..'\n'))
    table.insert(bigstring,string.format([=[plot '%s' using 1:2 notitle with points, f(x) title slope with lines]=]..'\n',global.prefix..fnames[4]))

    table.insert(bigstring,string.format('\n'..[=[set terminal png small transparent truecolor size %d,%d; set output '%s.png']=]..'\n',round(len*2+70,0),600,global.prefix..fnames[5]:sub(0,-5)))
    table.insert(bigstring,string.format([=[set title 'Plot of T vs sclY'; unset x2label]=]..'\n'))
    table.insert(bigstring,string.format([=[unset x2tics; unset mx2tics; set xtics out mirror; set mxtics 5; set xlabel 'Time (centiseconds)'; set xrange [0:%d]]=]..'\n',round(len,0)))
    table.insert(bigstring,string.format([=[set ytics out; set mytics 5; set ylabel 'Y Scale (Percent)'; set yrange [0:*] reverse]=]..'\n'))
    table.insert(bigstring,string.format([=[set grid xtics mxtics ytics mytics; stats '%s' using 1:2 name 'TvSYstat']=]..'\n',global.prefix..fnames[5]))
    table.insert(bigstring,string.format([=[f(x) = m*x + b; fit f(x) '%s' using 1:2 via m,b]=]..'\n',global.prefix..fnames[5]))
    table.insert(bigstring,string.format([=[if (b >= 0) slope = sprintf('Equation: scly(t) = %%.3ft + %%.3f : R^2: %%.3f',m,b,TvSYstat_correlation**2); else slope = sprintf('Equation: scly(t) = %%.3ft - %%.3f : R^2: %%.3f',m,0-b,TvSYstat_correlation**2)]=]..'\n'))
    table.insert(bigstring,string.format([=[plot '%s' using 1:2 notitle with points, f(x) title slope with lines]=]..'\n',global.prefix..fnames[5]))
  end
  if opts.rotation then
    table.insert(bigstring,string.format('\n'..[=[set terminal png small transparent truecolor size %d,%d; set output '%s.png']=]..'\n',round(len*2+70,0),600,global.prefix..fnames[6]:sub(0,-5)))
    table.insert(bigstring,string.format([=[set title 'Plot of T vs rot'; unset x2label]=]..'\n'))
    table.insert(bigstring,string.format([=[unset x2tics; unset mx2tics; set xtics out mirror; set mxtics 5; set xlabel 'Time (centiseconds)'; set xrange [0:%d]]=]..'\n',round(len,0)))
    table.insert(bigstring,string.format([=[set ytics out; set mytics 5; set ylabel 'Z Rotation (Degrees)'; set yrange [%d:%d] reverse]=]..'\n',round(mocha.rmin-1,0),round(mocha.rmax+1,0)))
    table.insert(bigstring,string.format([=[set grid xtics mxtics ytics mytics; stats '%s' using 1:2 name 'TvRstat']=]..'\n',global.prefix..fnames[6]))
    table.insert(bigstring,string.format([=[f(x) = m*x + b; fit f(x) '%s' using 1:2 via m,b]=]..'\n',global.prefix..fnames[6]))
    table.insert(bigstring,string.format([=[if (b >= 0) slope = sprintf('Equation: sclx(t) = %%.3ft + %%.3f : R^2: %%.3f',m,b,TvRstat_correlation**2); else slope = sprintf('Equation: sclx(t) = %%.3ft - %%.3f : R^2: %%.3f',m,0-b,TvRstat_correlation**2)]=]..'\n'))
    table.insert(bigstring,string.format([=[plot '%s' using 1:2 notitle with points, f(x) title slope with lines]=]..'\n',global.prefix..fnames[6]))
  end
  for k,v in pairs(fnames) do
    aegisub.log(5,"Export: opening %s for writing.\n",v)
    fhandle[k] = io.open(global.prefix..v,'w')
  end
  for x = 1, #mocha.xpos do
    if aegisub.progress.is_cancelled() then error("User cancelled") end
    local cs = (aegisub.ms_from_frame(accd.startframe+x-1) - aegisub.ms_from_frame(accd.startframe))/10 -- (normalized to start time)
    if opts.position then
      fhandle[1]:write(string.format("%g %g\n",mocha.xpos[x],mocha.ypos[x]))
      fhandle[2]:write(string.format("%g %g\n",cs,mocha.xpos[x]))
      fhandle[3]:write(string.format("%g %g\n",cs,mocha.ypos[x]))
    end
    if opts.scale then
      fhandle[4]:write(string.format("%g %g\n",cs,mocha.xscl[x]))
      fhandle[5]:write(string.format("%g %g\n",cs,mocha.yscl[x]))
    end
    if opts.rotation then
      fhandle[6]:write(string.format("%g %g\n",cs,mocha.zrot[x]))
    end
  end
  for i,v in ipairs(bigstring) do
    fhandle[7]:write(v)
  end
  for i,v in pairs(fhandle) do v:close() end
  if global.gnupauto then os.execute('cd "'..global.prefix..'" && gnuplot "'..fnames[7]..'"') end
end

function confmaker()
  local newgui = table.copy_deep(gui.main) -- OH JESUS CHRIST WHAT HAVE I DONE
  newgui.linespath, newgui.wconfig = nil
  newgui.encbin, newgui.pref = table.copy(newgui.pref), nil
  newgui.encbin.value, newgui.encbin.name = global.encbin, "encbin"
  newgui.datalabel.label = "       Enter the path to your prefix here (include trailing slash)."
  newgui.preflabel.label = "First box: path to encoder binary; second box: encoder command."
  newgui.windows  = { class = "checkbox"; value = global.windows; label = "Windows"; name = "windows";
                      x = 0; y = 21; height = 1; width = 3;}
  newgui.gui_trim = { class = "checkbox"; value = global.gui_trim; label = "Enable trim GUI"; name = "gui_trim";
                      x = 3; y = 21; height = 1; width = 4;}
  newgui.gnupauto = { class = "checkbox"; value = global.gui_expo; label = "Autoplot exports"; name = "gnupauto";
                      x = 7; y = 21; height = 1; width = 3;}
  newgui.enccom   = { class = "textbox"; value = global.enccom; name = "enccom";
                      x = 0; y = 17; height = 4; width = 10;}
  newgui.prefix   = { class = "textbox"; value = global.prefix; name = "prefix";
                      x = 0; y = 1; height = 4; width = 10;}
  newgui.encoder  = { class = "dropdown"; value = global.encoder; name = "encoder"; items = {"x264", "ffmpeg", "avs2yuv", "custom"};
                      x = 0; y = 10; height = 1; width = 2;}
  newgui.autocopy = { class = "checkbox"; value = global.windows; label = "Autocopy"; name = "autocopy";
                      x = 2; y = 10; height = 1; width = 3;}
  newgui.acfilter = { class = "checkbox"; value = global.windows; label = "Copy Filter"; name = "acfilter";
                      x = 5; y = 10; height = 1; width = 3;}
  local valtab = {}
  local cf = config_file
  if not (cf:match("^[A-Z]:\\") or cf:match("^/")) and dpath then
    aegisub.log(5,"herp\n")
    cf = io.open(aegisub.decode_path("?script/"..config_file))
    if not cf then
      cf = aegisub.decode_path("?user/"..config_file)
    else
      cf:close()
      cf = aegisub.decode_path("?script/"..config_file)
    end
  end
  if not readconf(cf,newgui) then aegisub.log(0,"Config read failed!") end
  newgui.enccom.value = encpre[newgui.encoder.value] or newgui.enccom.value
  local button, config = aegisub.dialog.display(newgui)
  if button then 
  for k,v in pairs(config) do
    aegisub.log(0,"config.%s = %s\n",tostring(k),tostring(v))
  end
  writeconf(cf,config) end
end --Adobe After Effects 6.0 Keyframe Data

aegisub.register_macro("Motion Data - Config", "Macro for full config editing.", confmaker, isvideo)

gui.t = {
  vidlabel = { class = "label"; label = "The path to the loaded video";
               x = 0; y = 0; height = 1; width = 30;},
  input    = { class = "textbox"; name = "input";
               x = 0; y = 1; height = 1; width = 30;},
  idxlabel = { class = "label"; label = "The path to the index file.";
               x = 0; y = 2; height = 1; width = 30;},
  index    = { class = "textbox"; name = "index";
               x = 0; y = 3; height = 1; width = 30;},
  sflabel  = { class = "label"; label = "Start frame";
               x = 0; y = 4; height = 1; width = 15;},
  startf   = { class = "intedit"; name = "startf";
               x = 0; y = 5; height = 1; width = 15;},
  eflabel  = { class = "label"; label = "End frame";
               x = 15; y = 4; height = 1; width = 15;},
  endf     = { class = "intedit"; name = "endf";
               x = 15; y = 5; height = 1; width = 15;},
  oplabel  = { class = "label"; label = "Video file to be written";
               x = 0; y = 6; height = 1; width = 30;},
  output   = { class = "textbox"; name = "output";
               x = 0; y = 7; height = 1; width = 30;},
}

function collecttrim(sub,sel,wc)
  wc.startt, wc.endt = sub[sel[1]].start_time, sub[sel[1]].end_time
  for i,v in ipairs(sel) do
    local l = sub[v]
    local lst, let = l.start_time, l.end_time
    if lst < wc.startt then wc.startt = lst end
    if let > wc.endt then wc.endt = let end
  end
  wc.startf, wc.endf = aegisub.frame_from_ms(wc.startt), aegisub.frame_from_ms(wc.endt)-1
  wc.lenf = wc.endf-wc.startf+1
  wc.lent = wc.endt-wc.startt
end
-- #{encbin} #{input} #{prefix} #{index} #{output} #{startf} #{lenf} #{endf} #{startt} #{lent} #{endt} #{nl}
function getvideoname(sub)
  for x = 1,#sub do
    if sub[x].class == "info" then
      if sub[x].key == "Video File" then
        local video = sub[x].value:sub(2)
        return video
      end
    end
  end
end

function trimnthings(sub,sel)
  local cf
  if not (config_file:match("^[A-Z]:\\") or config_file:match("^/")) and dpath then
    cf = io.open(aegisub.decode_path("?script/"..config_file))
    if not cf then
      cf = aegisub.decode_path("?user/"..config_file)
    else
      cf:close()
      cf = aegisub.decode_path("?script/"..config_file)
    end
  else
    cf = config_file
  end
  local gtab = {}
  for k,v in pairs(global) do gtab[k] = {} end
  if not readconf(cf,gtab) then aegisub.log(0,"Failed to read config!") end
  for k,v in pairs(gtab) do if v.value ~= nil then global[k] = v.value end end
  --global.enccom = encpre[global.encoder] or gtab[enccom]
  gtab = nil
  local wildc = {}
  wildc.encbin = global.encbin
  wildc.prefix = global.prefix
  wildc.nl = "\n"
  collecttrim(sub,sel,wildc)
  if dpath then
    local vid = getvideoname(sub):gsub("[A-Z]:\\",""):gsub(".-[^\\]\\","")
    assert(not vid:match("?dummy"), "No dummy videos allowed. Sorry.")
    wildc.input = aegisub.decode_path("?video")..vid
    wildc.index = vid:match("(.+)%.[^%.]+$")
    wildc.output = wildc.index..'-'..wildc.startf.."-%d"
  else
    wildc.input = getvideoname(sub)
    assert(not wildc.input:match("?dummy"), "No dummy videos allowed. Sorry.")
    wildc.index = wildc.input:gsub("[A-Z]:\\",""):gsub(".-[^\\]\\",""):match("(.+)%.[^%.]+$")
    wildc.output = wildc.index..'-'..wildc.startf.."-%d"
  end
  if dpath and not global.gui_trim then 
    writeandencode(wildc)
  else
    someguiorsmth(wildc)
  end
end

function someguiorsmth(wildc)
  gui.t.input.value = wildc.input
  gui.t.index.value = wildc.index
  gui.t.startf.value = wildc.startf
  gui.t.endf.value = wildc.endf
  gui.t.output.value = wildc.output
  local button, opts = aegisub.dialog.display(gui.t)
  if button then
    for k,v in pairs(opts) do
      wildc[k] = v
    end
    wildc.startt, wildc.endt = aegisub.ms_from_frame(wildc.startf), aegisub.ms_from_frame(wildc.endf)
    wildc.lenf, wildc.lent = wildc.endf-wildc.startf, wildc.endt-wildc.startt
    writeandencode(wildc)
  end
end

function writeandencode(wildc)
  local it = 0
  wildc.startt, wildc.endt, wildc.lent = wildc.startt/1000, wildc.endt/1000, wildc.lent/1000
  local function FormatWildCards(wc)
    return wildc[wc:sub(2,-2)]
  end
  repeat
    if aegisub.progress.is_cancelled() then error("User cancelled") end
    it = it + 1
    local n = string.format(wildc.output,it)
    local f = io.open(n,'r')
    if f then io.close(f); f = false else f = true; wildc.output = n end
  until f == true -- crappypasta
  if global.windows then
    local sh = io.open(global.prefix.."encode.bat","w+")
    assert(sh,"Encoding command could not be written. Check your prefix.") -- to solve the 250 byte limit, we write to a self-deleting batch file.
    sh:write(global.enccom:gsub("#(%b{})",FormatWildCards)..'\ndel %0')
    sh:close()
    os.execute(string.format("%q",global.prefix.."encode.bat"))
  else -- nfi what to do on lunix: dunno if it will allow execution of a shell script without explicitly setting the permissions. "x264 `cat x264opts.txt`" perhaps
    os.execute(global.encbin..' '..global.enccom..' --index "'..opts.index..'" --seek '..opts.startf..' --frames '..(opts.endf-opts.startf+1)..' -o "'..out..'" "'..opts.video..'"')
  end
end

aegisub.register_macro("Motion Data - Trim","Cuts and encodes the current scene for use with motion tracking software.", trimnthings, isvideo)