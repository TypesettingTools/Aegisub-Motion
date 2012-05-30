  --[=[ If a full path is provided, that config file will always be used. If a filename is provided,
        then we attempt to open that file in the script directory, and if that fails, then we open
        it in the aegisub userdata directory (%APPDATA%/Aegisub or ~/.aegisub). This allows different
        settings (prefix, etc) per-project if you desire. If you don't trust any of this crazy shit,
        then config_file = false will disable all config related operations.]=]--
config_file = "aegisub-motion.conf"
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
 10. THE USER must understand the difference between a COPYRIGHT LICENSE and an END-USER
    LICENSE AGREEMENT. COPYRIGHT LICENSES are THE THINGS that get put ON TOP of A PIECE
    OF CODE that tell people that YOU ARE NOT LEGALLY ALLOWED TO REDISTRIBUTE THIS FILE
    UNLESS YOU HAVE RECENTLY CASTRATED YOURSELF WITH A SPORK and even then only under
    SPECIFIC CIRCUMSTANCES. END-USER LICENSE AGREEMENTS are THE UNREADABLE WALLS OF
    LEGALESE that HUMONGOUS, PROFITABLE CORPORATIONS pay LEGIONS OF LEGAL PERSONELLE to
    develop that tell you that YOU ARE NOT LEGALLY ALLOWED TO USE THE SOFTWARE YOU JUST
    INSTALLED UNLESS YOU WILLINGLY CONSIGN YOUR ENTIRE ESTATE TO SAID CORPORATION IN
    YOUR LAST WILL AND TESTAMENT.
  ]=]--

script_name = "Aegisub-Motion"
script_description = "A set of tools for simplifying the process of creating and applying motion tracking data with Aegisub." -- and it might have memory issues. I think.
script_author = "torque"
script_version = "2.0.0.0.0.0" -- no, I have no idea how this versioning system works either.
require "karaskel"
if not aegisub.file_name then error("Aegisub 3.0.0 or better is required.") end
require "clipboard"

gui = {} -- I'm really beginning to think this shouldn't be a global variable
gui.main = { -- todo: change these to be more descriptive.
  linespath = { class = "textbox"; name = "linespath"; hint = "Paste data or the path to a file containing it. No quotes or escapes.";
                x = 0; y = 1; height = 4; width = 10;},
  pref      = { class = "textbox"; name = "pref"; hint = "The prefix";
                x = 0; y = 14; height = 3; width = 10; hint = "The directory any generated files will be written to."},
  preflabel = { class = "label"; label = "                  Files will be written to this directory.";
                x = 0; y = 13; height = 1; width = 10;},
  datalabel = { class = "label"; label = "                       Paste data or enter a filepath.";
                x = 0; y = 0; height = 1; width = 10;},
  optlabel  = { class = "label"; label = "Data to be applied:";
                x = 0; y = 6; height = 1; width = 5;},
  rndlabel  = { class = "label"; label = "Rounding";
                x = 7; y = 6; height = 1; width = 3;},
  xpos      = { class = "checkbox"; name = "xpos"; value = true; label = "x";
                x = 0; y = 7; height = 1; width = 1; hint = "Apply x position data to the selected lines."},
  ypos      = { class = "checkbox"; name = "ypos"; value = true; label = "y";
                x = 1; y = 7; height = 1; width = 1; hint = "Apply y position data to the selected lines."},
  origin    = { class = "checkbox"; name = "origin"; value = false; label = "Origin";
                x = 2; y = 7; height = 1; width = 2; hint = "Move the origin along with the position."},
  clip      = { class = "checkbox"; name = "clip"; value = false; label = "Clip";
                x = 4; y = 7; height = 1; width = 2; hint = "Move clip along with the position (note: will also be scaled and rotated if those options are selected)."},
  scale     = { class = "checkbox"; name = "scale"; value = true; label = "Scale";
                x = 0; y = 8; height = 1; width = 2; hint = "Apply scaling data to the selected lines."},
  border    = { class = "checkbox"; name = "border"; value = true; label = "Border";
                x = 2; y = 8; height = 1; width = 2; hint = "Scale border with the line (only if Scale is also selected)."},
  shadow    = { class = "checkbox"; name = "shadow"; value = true; label = "Shadow";
                x = 4; y = 8; height = 1; width = 2; hint = "Scale shadow with the line (only if Scale is also selected)."},
  rotation  = { class = "checkbox"; name = "rotation"; value = false; label = "Rotation";
                x = 0; y = 9; height = 1; width = 3; hint = "Apply rotation data to the selected lines."},
  posround  = { class = "intedit"; name = "posround"; value = 2; min = 0; max = 5;
                x = 7; y = 7; height = 1; width = 3; hint = "How many decimal places of accuracy the resulting positions should have."},
  sclround  = { class = "intedit"; name = "sclround"; value = 2; min = 0; max = 5;
                x = 7; y = 8; height = 1; width = 3; hint = "How many decimal places of accuracy the resulting scales should have (also applied to border and shadow)."},
  rotround  = { class = "intedit"; name = "rotround"; value = 2; min = 0; max = 5;
                x = 7; y = 9; height = 1; width = 3; hint = "How many decimal places of accuracy the resulting rotations should have."},
  wconfig   = { class = "checkbox"; name = "wconfig"; value = false; label = "Write config";
                x = 0; y = 11; height = 1; width = 4; hint = "Write current settings to the configuration file."},
  relative  = { class = "checkbox"; name = "relative"; value = true; label = "Relative";
                x = 4; y = 11; height = 1; width = 3; hint = "Start frame should be relative to the line's start time rather than to the start time of all selected lines"},
  stframe   = { class = "intedit"; name = "stframe"; value = 1;
                x = 7; y = 11; height = 1; width = 3; hint = "Frame used as the starting point for the tracking data. \"-1\" corresponds to the last frame."},
  vsfscale  = { class = "checkbox"; name = "vsfscale"; value = true; label = "VSfilter scaling";
                x = 0; y = 12; height = 1; width = 3; hint = "Use staged transforms to approximate noninteger scale values for vsfilter."},
  linear    = { class = "checkbox"; name = "linear"; value = false; label = "Linear";
                x = 4; y = 12; height = 1; width = 2; hint = "Use transforms and \\move to create a linear transition, instead of frame-by-frame."},
  export    = { class = "checkbox"; name = "export"; value = false; label = "Export";
                x = 8; y = 12; height = 1; width = 2; hint = "Write files for plotting data with gnuplot"},
  sortd     = { class = "dropdown"; name = "sortd"; hint = "Sort lines by"; value = "Default"; items = {"Default", "Time"};
                x = 5; y = 5; width = 4; height = 1; hint = "The order to sort the lines after they have been tracked."}, 
  sortlabel = { class = "label"; name = "sortlabel"; label = "      Sort Method:";
                x = 1; y = 5; width = 4; height = 1;},
}

gui.clip = {
  clippath = { class = "textbox"; name = "clippath"; hint = "Paste data or the path to a file containing it. No quotes or escapes.";
               x = 0; y = 1; height = 4; width = 10;},
  label    = { class = "label"; label = "                 Paste data or enter a filepath.";
               x = 0; y = 0; height = 1; width = 10;},
  xpos     = { class = "checkbox"; name = "xpos"; value = true; label = "x";
                x = 0; y = 6; height = 1; width = 1; hint = "Apply x position data to the selected lines."},
  ypos     = { class = "checkbox"; name = "ypos"; value = true; label = "y";
                x = 1; y = 6; height = 1; width = 1; hint = "Apply y position data to the selected lines."},
  scale    = { class = "checkbox"; name = "scale"; value = true; label = "Scale";
               x = 0; y = 7; height = 1; width = 2;},
  rotation = { class = "checkbox"; name = "rotation"; value = false; label = "Rotation";
               x = 0; y = 8; height = 1; width = 3;},
  relative = { class = "checkbox"; name = "relative"; value = true; label = "Relative";
                x = 4; y = 6; height = 1; width = 3;},
  stframe  = { class = "intedit"; name = "stframe"; value = 1;
                x = 7; y = 6; height = 1; width = 3;},
}

if config_file == "" then config_file = aegisub.decode_path("?user/aegisub-motion.conf") end

encpre = {
x264    = '"#{encbin}" --crf 16 --tune fastdecode -i 250 --fps 23.976 --sar 1:1 --index "#{prefix}#{index}.index" --seek #{startf} --frames #{lenf} -o "#{prefix}#{output}[#{startf}-#{endf}].mp4" "#{input}"',
ffmpeg  = '"#{encbin}" -ss #{startt} -t #{lent} -sn -i "#{input}" "#{prefix}#{output}[#{startf}-#{endf}]-%%05d.jpg"',
avs2yuv = 'echo FFVideoSource("#{input}",cachefile="#{prefix}#{index}.index").trim(#{startf},#{endf}).ConvertToRGB.ImageWriter("#{prefix}#{output}[#{startf}-#{endf}].",type="png") > "#{prefix}encode.avs"#{nl}"#{encbin}" -o NUL "#{prefix}encode.avs"#{nl}del "#{prefix}encode.avs"',}

global = {
  windows  = true, -- try to use windows style paths
  prefix   = "",
  encoder  = "x264",
  encbin   = "",
  gui_trim = true,
  gnupauto = false,
  autocopy = true,
  acfilter = true,
  delsourc = false, 
  -- encoder presets
}

global.enccom = encpre[global.encoder] or ""

gui.conf = table.copy_deep(gui.main)
gui.conf.clippath, gui.conf.linespath, gui.conf.wconfig = nil
gui.conf.encbin, gui.conf.pref = table.copy(gui.conf.pref), nil
gui.conf.encbin.value, gui.conf.encbin.name = global.encbin, "encbin"
gui.conf.encbin.hint = "The full path to the encoder binary (unless it's in your PATH)"
gui.conf.datalabel.label = "       Enter the path to your prefix here (include trailing slash)."
gui.conf.preflabel.label = "First box: path to encoder binary; second box: encoder command."
gui.conf.windows  = { class = "checkbox"; value = global.windows; label = "Windows"; name = "windows";
                    x = 0; y = 22; height = 1; width = 3; hint = "Check this if you are running this on windows."}
gui.conf.gui_trim = { class = "checkbox"; value = global.gui_trim; label = "Enable trim GUI"; name = "gui_trim";
                    x = 3; y = 22; height = 1; width = 4; hint = "Set whether or not the trim gui should appear."}
gui.conf.gnupauto = { class = "checkbox"; value = global.gui_expo; label = "Autoplot exports"; name = "gnupauto";
                    x = 7; y = 22; height = 1; width = 3; hint = "Will attempt to automatically plot with gnuplot on export (only works if it is in your PATH)"}
gui.conf.enccom   = { class = "textbox"; value = global.enccom; name = "enccom";
                    x = 0; y = 17; height = 4; width = 10; hint = "The encoding command that will be used. If you change this, set the preset to \"custom\"."}
gui.conf.prefix   = { class = "textbox"; value = global.prefix; name = "prefix";
                    x = 0; y = 1; height = 4; width = 10; hint = "The folder to which all generated files will be written."}
gui.conf.encoder  = { class = "dropdown"; value = global.encoder; name = "encoder"; items = {"x264", "ffmpeg", "avs2yuv", "custom"};
                    x = 0; y = 11; height = 1; width = 2; hint = "Choose one of the encoding command presets (set to custom if you have made any modifications to the defaults)"}
gui.conf.delsourc = { class = "checkbox"; value = global.delsourc; label = "Delete"; name = "delsourc";
                    x = 0; y = 21; height = 1; width = 2; hint = "Delete the source lines instead of commenting them out."}
gui.conf.autocopy = { class = "checkbox"; value = global.autocopy; label = "Autocopy"; name = "autocopy";
                    x = 3; y = 21; height = 1; width = 3; hint = "Automatically copy the contents of the clipboard into the tracking data box on script run."}
gui.conf.acfilter = { class = "checkbox"; value = global.acfilter; label = "Copy Filter"; name = "acfilter";
                    x = 7; y = 21; height = 1; width = 3; hint = "Only automatically copy the clipboard if it appears to contain tracking data."}

alltags = {
  ['xscl']  = "\\fscx([%d%.]+)",
  ['yscl']  = "\\fscy([%d%.]+)",
  ['ali']   = "\\an([1-9])",
  ['zrot']  = "\\frz?([%-%d%.]+)",
  ['bord']  = "\\bord([%d%.]+)",
  ['xbord'] = "\\xbord([%d%.]+)",
  ['ybord'] = "\\ybord([%d%.]+)",
  ['shad']  = "\\shad([%-%d%.]+)",
  ['xshad'] = "\\xshad([%-%d%.]+)",
  ['yshad'] = "\\yshad([%-%d%.]+)",
  ['reset'] = "\\r([^\\}]*)",
  ['alpha'] = "\\alpha&H(%x%x)&",
  ['l1a']   = "\\1a&H(%x%x)&",
  ['l2a']   = "\\2a&H(%x%x)&",
  ['l3a']   = "\\3a&H(%x%x)&",
  ['l4a']   = "\\4a&H(%x%x)&",
  ['l1c']   = "\\c&H(%x+)&",
  ['l1c2']  = "\\1c&H(%x+)&",
  ['l2c']   = "\\2c&H(%x+)&",
  ['l3c']   = "\\3c&H(%x+)&",
  ['l4c']   = "\\4c&H(%x+)&",
  ['clip']  = "\\clip%((.-)%)",
  ['iclip'] = "\\iclip%((.-)%)",
  ['be']    = "\\be([%d%.]+)",
  ['blur']  = "\\blur([%d%.]+)",
  ['fax']   = "\\fax([%-%d%.]+)",
  ['fay']   = "\\fay([%-%d%.]+)"
}

importanttags = { -- scale_x, scale_y, outline, shadow, angle
  ['\\fscx'] = {{"scale","scale"}, "scale_x"};
  ['\\fscy'] = {{"scale","scale"}, "scale_y"};
  ['\\bord'] = {{"border","scale"}, "outline"};
  ['\\shad'] = {{"shadow","scale"}, "shadow"};
  ['\\frz']  = {{"rotation","rotation"}, "angle"};
}

guiconf = {
  main = {
    "sortd",
    "xpos", "ypos", "origin", "clip", "posround",
    "scale", "border", "shadow", "sclround",
    "rotation", "rotround",
    "relative", "stframe",
    "vsfscale", "export", "linear",
  },
  clip = {
    "xpos", "ypos", "scale", "rotation",
    "relative","stframe",
  },
}

for k,v in pairs(global) do table.insert(guiconf,k) end

function dcos(a) return math.cos(math.rad(a)) end
function dacos(a) return math.deg(math.acos(a)) end
function dsin(a) return math.sin(math.rad(a)) end
function dasin(a) return math.deg(math.asin(a)) end
function dtan(a) return math.tan(math.rad(a)) end
function datan(y,x) return math.deg(math.atan2(y,x)) end

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
    local thesection
    for line in cf:lines() do
      local section = line:match("#(%w+)")
      if section then
        valtab[section] = {}
        thesection = section
        aegisub.log(5,"Section: %s\n",thesection)
      elseif thesection == nil then
        return nil
      else
        local key, val = line:splitconf()
        aegisub.log(5,"Read: %s -> %s\n", key, tostring(val:tobool()))
        valtab[thesection][key:gsub("^ +","")] = val:tobool()
      end
    end
    cf:close()
    convertfromconf(valtab,guitab)
    return true
  else
    return nil
  end
end

function convertfromconf(valtab,guitab)
  --aegisub.log(5,"%s\n",table.tostring(guitab))
  for section,sectab in pairs(guitab) do
    for ident,value in pairs(valtab[section]) do
      if section == "global" then
        aegisub.log(5,"Set: global.%s = %s (%s)\n",ident,tostring(value),type(value))
        sectab[ident] = value
      else
        if sectab[ident] then
          aegisub.log(5,"Set: gui.%s.%s = %s (%s)\n",section,ident,tostring(value),type(value))
          sectab[ident].value = value
        end
      end
    end
  end
end

function writeconf(conf,optab)
  local cf = io.open(conf,'w+')
  if not cf then 
    aegisub.log(0,'Config write failed! Check that %s exists and has write permission.\n',cf)
    return nil
  end
  local configlines = {}
  for section,tab in pairs(optab) do
    table.insert(configlines,("#%s\n"):format(section))
    if section == "global" then
      for ident,value in pairs(tab) do
        table.insert(configlines,("  %s:%s\n"):format(ident,tostring(value)))
      end
    else
      for i, field in ipairs(guiconf[section]) do
        if tab[field] ~= nil then -- (e.g. when clipconf == {}, don't overwrite all the config with "nil")
          table.insert(configlines,("  %s:%s\n"):format(field,tostring(tab[field])))
        end
      end
    end
  end
  for i,v in ipairs(configlines) do
    aegisub.log(5,"Write: %s -> config\n",v:gsub("^ +",""))
    cf:write(v)
  end
  cf:close()
  return true
end

function configscope()
  local cf
  if tostring(config_file):match("^[A-Z]:\\") or tostring(config_file):match("^/") or not config_file then
    return config_file
  else
    cf = io.open(aegisub.decode_path("?script/"..config_file))
    if not cf then
      cf = aegisub.decode_path("?user/"..config_file)
    else
      cf:close()
      cf = aegisub.decode_path("?script/"..config_file)
    end
    return cf
  end
end

function string:splitconf()
  local line = self:gsub("[\r\n]*","")
  return line:match("^(.-):(.*)$")
end

function string:tobool()
  local bool = ({['true'] = true, ['false'] = false})[self]
  if bool ~= nil then return bool
    else return self; end
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
  line.trans = {}
  for a in line.text:gmatch("%{(.-)}") do
    aegisub.log(5,"Found a comment/override block in line %d: %s\n",num,a)
    local function cconv(a,b,c,d,e)
      line.clips = a
      line.clip = string.format("m %d %d l %d %d %d %d %d %d",b,c,d,c,d,e,b,e)
    end
    a:gsub("\\(i?clip)%(([%-%d]+),([%-%d]+),([%-%d]+),([%-%d]+)%)",cconv,1) -- hum
    if not line.clip then
      line.clips, line.sclip, line.clip = a:match("\\(i?clip)%(([%d]*),?(.-)%)")
    end
    if line.clip then
      line.sclip = tonumber(line.sclip) or false
      if line.sclip then aegisub.log(5,"Clip: \\%s(%s,%s)\n",line.clips,line.sclip,line.clip)
      else aegisub.log(5,"Clip: \\%s(%s)\n",line.clips,line.clip) end
    end -- because otherwise it crashes!
    for c in a:gmatch("\\t(%b())") do -- this will return an empty string for t_exp if no exponential factor is specified
      t_start,t_end,t_exp,t_eff = c:sub(2,-2):match("([%-%d]+),([%-%d]+),([%d%.]*),?(.+)")
      t_exp = tonumber(t_exp) or 1 -- set to 1 if unspecified
      table.insert(line.trans,{tonumber(t_start),tonumber(t_end),tonumber(t_exp),t_eff})
      aegisub.log(5,"Line %d: \\t(%g,%g,%g,%s) found\n",num,t_start,t_end,t_exp,t_eff)
    end
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
  accd.lines = {}
  accd.endframe = aegisub.frame_from_ms(sub[sel[1]].end_time) -- get the end frame of the first selected line
  accd.startframe = aegisub.frame_from_ms(sub[sel[1]].start_time) -- get the start frame of the first selected line
  local numlines = #sel
  for i = #sel,1,-1 do -- burning cpu cycles like they were no thing
    local opline = sub[sel[i]] -- these are different.
    opline.num = sel[i] -- for inserting lines later
    karaskel.preproc_line(sub, accd.meta, accd.styles, opline) -- get linewidth/height and margins
    if not opline.effect then opline.effect = "" end
    getinfo(sub, opline, opline.num-strt)
    opline.startframe, opline.endframe = aegisub.frame_from_ms(opline.start_time), aegisub.frame_from_ms(opline.end_time)
    if opline.comment then opline.is_comment = true else opline.is_comment = false end
    if opline.startframe < accd.startframe then -- make timings flexible. Number of frames total has to match the tracked data but
      aegisub.log(5,"Line %d: startframe changed from %d to %d\n",opline.num-strt,accd.startframe,opline.startframe)
      accd.startframe = opline.startframe
    end
    if opline.endframe > accd.endframe then -- individual lines can be shorter than the whole scene
      aegisub.log(5,"Line %d: endframe changed from %d to %d\n",opline.num-strt,accd.endframe,opline.endframe)
      accd.endframe = opline.endframe
    end
    if opline.endframe-opline.startframe>1 then
      table.insert(accd.lines,opline)
    end
  end
  local length = #accd.lines
  accd.totframes = accd.endframe - accd.startframe
  assert(#accd.lines>0,"You have to select at least one line that is longer than one frame long.") -- pro error checking
  printmem("End of preproc loop")
  return accd
end

function init_input(sub,sel) -- THIS IS PROPRIETARY CODE YOU CANNOT LOOK AT IT
  aegisub.progress.title("Selecting Gerbils")
  local accd = preprocessing(sub,sel)
  gui.main.stframe.min = -accd.totframes; gui.main.stframe.max = accd.totframes;
  gui.clip.stframe.min = -accd.totframes; gui.clip.stframe.max = accd.totframes;
  local conf = configscope()
  if conf then
    if not readconf(conf,{ ['main'] = gui.main; ['clip'] = gui.clip; ['global'] = global }) then aegisub.log(0,"Failed to read config!\n") end
  end
  if global.autocopy then
    local paste = clipboard.get() or "" -- if nothing on the clipboard then returns nil
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
  local button, config = aegisub.dialog.display(gui.main, {"Go","Clip...","Export","Abort"})
  local clipconf
  if button == "Clip..." then
    button, clipconf = aegisub.dialog.display(gui.clip, {"Go","Cancel","Abort"})
  end
  if button == "Go" then
    local clipconf = clipconf or {} -- solve indexing errors
    for i,field in ipairs(guiconf.clip) do
      if clipconf[field] == nil then clipconf[field] = gui.clip[field].value end
    end
    if config.linespath == "" then config.linespath = false end
    if config.wconfig then
      writeconf(conf,{ ['main'] = config; ['clip'] = clipconf; ['global'] = global })
    end
    if config.stframe == 0 then config.stframe = 1 end
    if clipconf.stframe == 0 then clipconf.stframe = 1 end
    if config.xpos or config.ypos then config.position = true end
    config.yconst = not config.ypos; config.xconst = not config.xpos
    if clipconf.xpos or clipconf.ypos then clipconf.position = true end
    clipconf.yconst = not clipconf.ypos; clipconf.xconst = not clipconf.xpos
    if clipconf.clippath == "" or clipconf.clippath == nil then
      clipconf.clippath = false
    else config.clip = false end -- set clip to false if clippath exists
    if config.clip or clipconf.clippath then config.linear = false end
    aegisub.progress.title("Mincing Gerbils")
    printmem("Go")
    local newsel = frame_by_frame(sub,accd,config,clipconf)
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
    local mochatab = {}
    parse_input(config.linespath,mochatab,accd.meta.res_x,accd.meta.res_y)
    export(accd,mochatab,config)
  elseif button == "Cancel" then
    init_input(sub,sel) -- this is extremely unideal as it reruns all of the information gathering functions as well.
  else
    aegisub.progress.task("ABORT")
    aegisub.cancel()
  end
  aegisub.set_undo_point("Motion Data")
  printmem("Closing")
end

function parse_input(mocha_table,input,shx,shy)
  printmem("Start of input parsing")
  local ftab = {}
  local sect, care = 0, 0
  mocha_table.xpos, mocha_table.ypos, mocha_table.xscl, mocha_table.yscl, mocha_table.zrot = {}, {}, {}, {}, {}
  local datams = io.open(input,"r") -- a terrible idea? Doesn't seem to be so far.
  local datastring = ""
  if datams then
    for line in datams:lines() do
      line = line:gsub("[\r\n]*","") -- FUCK YOU CRLF
      datastring = datastring..line.."\n"
      table.insert(ftab,line) -- dump the lines from the file into a table.
    end 
    datams:close()
  else
    input = input:gsub("[\r]*","") -- SERIOUSLY FUCK THIS SHIT
    datastring = input
    ftab = input:split("\n")
  end
  local xmult,ymult
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
  initmaxmin(mocha_table,datastring)
  xmult = shx/tonumber(sw)
  ymult = shy/tonumber(sh)
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
        local x = tonumber(val[2])
        table.insert(mocha_table.xpos,x*xmult)
        if x > mocha_table.xmax then mocha_table.xmax = x
        elseif x < mocha_table.xmin then mocha_table.xmin = x end
        local y = tonumber(val[3])
        table.insert(mocha_table.ypos,y*ymult)
        if y > mocha_table.ymax then mocha_table.ymax = y
        elseif y < mocha_table.ymin then mocha_table.ymin = y end
      end
    elseif sect <= 3 and sect >= 2 then
      if valu:match("%d") then
        val = valu:split("\t")
        local xs = tonumber(val[2])
        table.insert(mocha_table.xscl,xs)
        if xs > mocha_table.xsmax then mocha_table.xsmax = xs
        elseif xs < mocha_table.xsmin then mocha_table.xsmin = xs end
        local ys = tonumber(val[3])
        table.insert(mocha_table.yscl,ys)
        if ys > mocha_table.ysmax then mocha_table.ysmax = ys
        elseif ys < mocha_table.ysmin then mocha_table.ysmin = ys end
      end
    elseif sect <= 7 and sect >= 4 then
      if valu:match("%d") then
        val = valu:split("\t")
        local r = -tonumber(val[2])
        table.insert(mocha_table.zrot,r)
        if r > mocha_table.rmax then mocha_table.rmax = -r
        elseif r < mocha_table.rmin then mocha_table.rmin = -r end
      end
    end
  end
  mocha_table.flength = #mocha_table.xpos
  assert(mocha_table.flength == #mocha_table.ypos and mocha_table.flength == #mocha_table.xscl and mocha_table.flength == #mocha_table.yscl and mocha_table.flength == #mocha_table.zrot,"The data is not internally equal length.") -- make sure all of the elements are the same length (because I don't trust my own code).
  printmem("End of input parsing")
end

function initmaxmin(mocha_table,datastring)
  mocha_table.xmax, mocha_table.ymax = datastring:match("Position\n\tFrame\tX pixels\tY pixels\tZ pixels\n\t%d+\t([%d%-%.]+)\t([%d%-%.]+)")
  mocha_table.xsmax, mocha_table.ysmax = datastring:match("Scale\n\tFrame\tX percent\tY percent\tZ percent\n\t%d+\t([%d%-%.eE%+]+)\t([%d%-%.eE%+]+)") -- uses e notation, e.g. 6.65107e+41
  mocha_table.rmax = datastring:match("Rotation\n\tFrame\tDegrees\n\t%d+\t([%d%-%.eE%+]+)")
  mocha_table.xmax, mocha_table.xmin = tonumber(mocha_table.xmax), tonumber(mocha_table.xmax) -- probably a much better way to do this
  mocha_table.ymax, mocha_table.ymin = tonumber(mocha_table.ymax), tonumber(mocha_table.ymax)
  mocha_table.xsmax, mocha_table.xsmin = tonumber(mocha_table.xsmax), tonumber(mocha_table.xsmax)
  mocha_table.ysmax, mocha_table.ysmin = tonumber(mocha_table.ysmax), tonumber(mocha_table.ysmax)
  mocha_table.rmax, mocha_table.rmin = tonumber(mocha_table.rmax), tonumber(mocha_table.rmax)
end

function spoof_table(parsed_table,opts,len)
  local len = len or #parsed_table.xpos
  parsed_table.xpos = parsed_table.xpos or {}
  parsed_table.ypos = parsed_table.ypos or {}
  parsed_table.xscl = parsed_table.xscl or {}
  parsed_table.yscl = parsed_table.yscl or {}
  parsed_table.zrot = parsed_table.zrot or {}
  if not opts.position then
    for k = 1,len do
      parsed_table.xpos[k] = 0
      parsed_table.ypos[k] = 0
    end
  else
    if opts.yconst then
      for k = 1,len do
        parsed_table.ypos[k] = 0
      end
    end
    if opts.xconst then
      for k = 1,len do
        parsed_table.xpos[k] = 0
      end
    end
  end
  if not opts.scale then
    for k = 1,len do
      parsed_table.xscl[k] = 100
      parsed_table.yscl[k] = 100
    end
  end
  if not opts.rotation then
    for k = 1,len do
      parsed_table.zrot[k] = 0
    end
  end
  parsed_table.s = 1
  if opts.reverse then parsed_table.s = parsed_table.flength end
end

function ensuretags(line,opts,styles,dim)
  if line.margin_v ~= 0 then line._v = line.margin_v else line._v = line.styleref.margin_v end
  if line.margin_l ~= 0 then line._l = line.margin_l else line._l = line.styleref.margin_l end
  if line.margin_r ~= 0 then line._r = line.margin_r else line._r = line.styleref.margin_r end
  line.ali = line.text:match("\\an([1-9])") or line.styleref.align
  line.xpos,line.ypos = line.text:match("\\pos%(([%-%d%.]+),([%-%d%.]+)%)")
  if not line.xpos then -- insert position into line if not present.
    line.xpos = fix.xpos[line.ali%3+1](dim.x,line._l,line._r)
    line.ypos = fix.ypos[math.ceil(line.ali/3)](dim.y,line._v)
    line.text = (("{\\pos(%d,%d)}"):format(line.xpos,line.ypos)..line.text):gsub("^({.-)}{","%1")
  end
  line.oxpos,line.oypos = line.text:match("\\org%(([%-%d%.]+),([%-%d%.]+)%)") or line.xpos,line.ypos
  line.origindx,line.origindy = line.xpos - line.oxpos, line.ypos - line.oypos 
  local mergedtext = line.text:gsub("}{","")
  local startblock = mergedtext:match("^{(.-)}")
  local block = ""
  if startblock then
    for tag, str in pairs(importanttags) do
      if opts[str[1][1]] and opts[str[1][2]] and not startblock:match(tag.."[%-%d%.]+") then
        block = block..(tag.."%f"):format(line.styleref[str[2]])
      end
    end
    if block:len() > 0 then
      line.text = ("{"..block.."}"..line.text):gsub("^({.-)}{","%1")
    end
  else
    for tag, str in pairs(importanttags) do
      if opts[str[1][1]] and opts[str[1][2]] then
        block = block..(tag.."%f"):format(line.styleref[str[2]])
      end
    end
    line.text = "{"..block.."}"..line.text
  end
  function resetti(before,rstyle,rest)
    local styletab = styles[rstyle] or line.styleref -- if \\r[stylename] is not a real style, reverts to regular \r
    local block = ""
    for tag, str in pairs(importanttags) do
      if opts[str[1][1]] and opts[str[1][2]] and not startblock:match(tag.."[%-%d%.]+") then
        block = block..(tag.."%f"):format(styletab[str[2]])
      end
    end
    return "{"..before..rstyle..block..rest.."}"
  end
  line.text = line.text:gsub("{([^}]*\\r)([^\\}]*)(.-)}",resetti)
end

function frame_by_frame(sub,accd,opts,clipopts)
  printmem("Start of main loop")
  local dim = {x = accd.meta.res_x; y = accd.meta.res_y}
  local mocha = {}
  local clipa = {}
  if opts.linespath then
    parse_input(mocha,opts.linespath,accd.meta.res_x,accd.meta.res_y)
    assert(accd.totframes==mocha.flength,string.format("Number of frames selected (%d) does not match parsed line tracking data length (%d).",accd.totframes,mocha.flength))
    spoof_table(mocha,opts)
    if not opts.relative then
      if opts.stframe < 0 then
        mocha.start = accd.totframes + opts.stframe + 1
      else
        mocha.start = opts.stframe
      end
    end
    if opts.clip then clipa = mocha end
  end
  if clipopts.clippath then
    parse_input(clipa,clipopts.clippath,accd.meta.res_x,accd.meta.res_y)
    assert(accd.totframes==clipa.flength,string.format("Number of frames selected (%d) does not match parsed clip tracking data length (%d).",accd.totframes,clipa.flength))
    opts.linear = false -- no linear mode with moving clip, sorry
    opts.clip = true -- simplify things a bit
    spoof_table(clipa,clipopts)
    if not opts.linespath then spoof_table(mocha,opts,#clipa.xpos) end
    if not clipopts.relative then
      if clipopts.stframe < 0 then
        clipa.start = accd.totframes + clipopts.stframe + 1
      else
        clipa.start = clipopts.stframe
      end
    end
  end
  if opts.export then export(accd,mocha,opts) end
  for k,v in ipairs(accd.lines) do -- comment lines that were commented in the thingy
    local derp = sub[v.num]
    derp.comment = true
    sub[v.num] = derp
    if not v.is_comment then v.comment = false end
  end
  local _ = nil
  local newlines = {} -- table to stick indices of tracked lines into for cleanup.
  local operations = {} -- create a table and put the necessary functions into it, which will save a lot of if operations in the inner loop. This was the most elegant solution I came up with.
  if opts.position then
    operations["(\\pos)%(([%-%d%.]+,[%-%d%.]+)%)"] = possify
    if opts.origin then
      operations["(\\org)%(([%-%d%.]+,[%-%d%.]+)%)"] = orginate
    end
  end
  if opts.scale then
    if opts.vsfscale then
      opts.sclround = 2
      operations["(\\fsc[xy])([%d%.]+)"] = VSscalify
    else
      operations["(\\fsc[xy])([%d%.]+)"] = scalify
    end
    if opts.border then
      operations["(\\[xy]?bord)([%d%.]+)"] = scalify
    end
    if opts.shadow then
      operations["(\\[xy]?shad)([%-%d%.]+)"] = scalify
    end
  end
  if opts.rotation then
    operations["(\\frz?)([%-%d%.]+)"] = rotate
  end
  printmem("End of table insertion")
  local function linearmodo(currline)
    local one = aegisub.ms_from_frame(aegisub.frame_from_ms(currline.start_time))
    local two = aegisub.ms_from_frame(aegisub.frame_from_ms(currline.start_time)+1)
    local red = currline.start_time
    local blue = currline.end_time
    local three = aegisub.ms_from_frame(aegisub.frame_from_ms(currline.end_time)-1)
    local four = aegisub.ms_from_frame(aegisub.frame_from_ms(currline.end_time))
    local maths = math.floor(one-red+(two-one)/2) -- this voodoo magic gets the time length (in ms) from the start of the first subtitle frame to the actual start of the line time.
    local mathsanswer = math.floor(blue-red+three-blue+(four-three)/2) -- and this voodoo magic is the total length of the line plus the difference (which is negative) between the start of the last frame the line is on and the end time of the line.
    local posmatch = "(\\pos)%(([%-%d%.]+,[%-%d%.]+)%)"
    if operations[posmatch] then
      currline.text = currline.text:gsub(posmatch,function(tag,val)
        local exes, whys = {}, {}
        for i,x in pairs({currline.rstartf,currline.rendf}) do
          local cx,cy = val:match("([%-%d%.]+),([%-%d%.]+)")
          mocha.ratx = mocha.xscl[x]/mocha.xscl[mocha.start]
          mocha.raty = mocha.yscl[x]/mocha.yscl[mocha.start]
          mocha.xdiff = mocha.xpos[x]-mocha.xpos[mocha.start]
          mocha.ydiff = mocha.ypos[x]-mocha.ypos[mocha.start]
          mocha.zrotd = mocha.zrot[x]-mocha.zrot[mocha.start]
          mocha.currx,mocha.curry = mocha.xpos[x],mocha.ypos[x]
          cx,cy = makexypos(tonumber(cx),tonumber(cy),currline.alpha,mocha)
          table.insert(exes,round(cx,opts.posround)); table.insert(whys,round(cy,opts.posround))
        end
        local s = ("\\move(%g,%g,%g,%g,%d,%d)"):format(exes[1],whys[1],exes[2],whys[2],maths,mathsanswer)
        aegisub.log(5,"%s\n",s)
        return s
      end)
      operations[posmatch] = nil
    end
    for pattern,func in pairs(operations) do -- iterate through the necessary operations
      if aegisub.progress.is_cancelled() then error("User cancelled") end
      currline.text = currline.text:gsub(pattern,function(tag,val) 
        local values = {}
        for i,x in pairs({currline.rstartf,currline.rendf}) do
          mocha.ratx = mocha.xscl[x]/mocha.xscl[mocha.start]
          mocha.raty = mocha.yscl[x]/mocha.yscl[mocha.start]
          mocha.xdiff = mocha.xpos[x]-mocha.xpos[mocha.start]
          mocha.ydiff = mocha.ypos[x]-mocha.ypos[mocha.start]
          mocha.zrotd = mocha.zrot[x]-mocha.zrot[mocha.start]
          mocha.currx,mocha.curry = mocha.xpos[x],mocha.ypos[x]
          table.insert(values,func(val,currline,mocha,opts))
        end
        return ("%s%g\\t(%d,%d,1,%s%g)"):format(tag,values[1],maths,mathsanswer,tag,values[2])
      end)
    end
    sub[currline.num] = currline
  end
  local function nonlinearmodo(currline)
    for x = currline.rendf,currline.rstartf,-1 do -- new inner loop structure
      printmem("Inner loop")
      aegisub.progress.title(string.format("Processing frame %g/%g",x,currline.rendf-currline.rstartf+1))
      aegisub.progress.set((x-currline.rstartf)/(currline.rendf-currline.rstartf)*100)
      if aegisub.progress.is_cancelled() then error("User cancelled") end
      currline.start_time = aegisub.ms_from_frame(accd.startframe+x-1)
      currline.end_time = aegisub.ms_from_frame(accd.startframe+x)
      if not currline.is_comment then -- don't do any math for commented lines.
        currline.time_delta = currline.start_time - aegisub.ms_from_frame(accd.startframe)
        for vk,kv in ipairs(currline.trans) do
          if aegisub.progress.is_cancelled() then error("User cancelled") end
          currline.text = transformate(currline,kv)
        end
        mocha.ratx = mocha.xscl[x]/mocha.xscl[mocha.start] -- DIVISION IS SLOW
        mocha.raty = mocha.yscl[x]/mocha.yscl[mocha.start]
        mocha.xdiff = mocha.xpos[x]-mocha.xpos[mocha.start]
        mocha.ydiff = mocha.ypos[x]-mocha.ypos[mocha.start]
        mocha.zrotd = mocha.zrot[x]-mocha.zrot[mocha.start]
        mocha.currx,mocha.curry = mocha.xpos[x],mocha.ypos[x]
        for pattern,func in pairs(operations) do -- iterate through the necessary operations
          if aegisub.progress.is_cancelled() then error("User cancelled") end
          currline.text = currline.text:gsub(pattern,function(tag,val) return tag..func(val,currline,mocha,opts,tag) end)
        end
        if clipme then
          currline.text = currline.text:gsub("\\clip%(.-%)",function(a) return clippinate(currline,clipa,x) end,1)
        end
        currline.text = currline.text:gsub('\1',"")
      end
      sub.insert(currline.num+1,currline)
      currline.text = currline.orgtext
    end
    if global.delsourc then sub.delete(currline.num) end
  end
  local how2proceed = nonlinearmodo
  if opts.linear then
    how2proceed = linearmodo
  end
  for i,currline in ipairs(accd.lines) do
    printmem("Outer loop")
    currline.rstartf = currline.startframe - accd.startframe + 1 -- start frame of line relative to start frame of tracked data
    currline.rendf = currline.endframe - accd.startframe -- end frame of line relative to start frame of tracked data
    local clipme = false
    if opts.clip and currline.clip then
      clipme = true -- use this in the inner loop because it only needs to be calculated once per line.
    end
    currline.effect = "aa-mou"..currline.effect
    if opts.relative then
      if opts.stframe < 0 then
        mocha.start = currline.rendf + opts.stframe + 1
      else
        mocha.start = currline.rstartf + opts.stframe - 1
      end
    end
    if clipopts.relative and clipme then
      if tonumber(clipopts.stframe) < 0 then
        clipa.start = currline.rendf + clipopts.stframe + 1
      else
        clipa.start = currline.rstartf + clipopts.stframe - 1
      end
    end
    ensuretags(currline,opts,accd.styles,dim)
    currline.alpha = -datan(currline.ypos-mocha.ypos[mocha.start],currline.xpos-mocha.xpos[mocha.start])
    if opts.origin then currline.beta = -datan(currline.oypos-mocha.ypos[mocha.start],currline.oxpos-mocha.xpos[mocha.start]) end
    currline.orgtext = currline.text -- tables are passed as references.
    how2proceed(currline)
  end
  for x = #sub,1,-1 do
    if tostring(sub[x].effect):match("^aa%-mou") then
      aegisub.log(5,"I choose you, %d!\n",x)
      table.insert(newlines,x) -- seems to work as intended
    end
  end
  return newlines -- yeah mang
end

function possify(pos,line,mocha,opts)
  local oxpos,oypos = pos:match("([%-%d%.]+),([%-%d%.]+)")
  local xpos,ypos = makexypos(tonumber(oxpos),tonumber(oypos),line.alpha,mocha)
  aegisub.log(5,"pos: (%f,%f) -> (%f,%f)\n",oxpos,oypos,xpos,ypos)
  return ("(%g,%g)"):format(round(xpos,opts.posround),round(ypos,opts.posround))
end

function makexypos(xpos,ypos,alpha,mocha)
  local xpos = (xpos + mocha.xdiff)*mocha.ratx + (1 - mocha.ratx)*mocha.currx
  local ypos = (ypos + mocha.ydiff)*mocha.raty + (1 - mocha.raty)*mocha.curry
  local r = math.sqrt((xpos - mocha.currx)^2+(ypos - mocha.curry)^2)
  xpos = mocha.currx + r*dcos(alpha + mocha.zrotd)
  ypos = mocha.curry - r*dsin(alpha + mocha.zrotd)
  return xpos,ypos
end

function orginate(opos,line,mocha,opts) -- this will be changed.
  local oxpos,oypos = opos:match("([%-%d%.]+),([%-%d%.]+)")
  local xpos,ypos = makexypos(tonumber(oxpos),tonumber(oypos),line.alpha,mocha)
  aegisub.log(5,"org: (%f,%f) -> (%f,%f)\n",oxpos,oypos,xpos,ypos)
  return ("(%g,%g)"):format(round(xpos,opts.posround),round(ypos,opts.posround))
end

function clippinate(line,clipa,iter)
  local cx, cy = clipa.xpos[iter], clipa.ypos[iter]
  local ratx, raty = clipa.xscl[iter]/clipa.xscl[clipa.start], clipa.yscl[iter]/clipa.yscl[clipa.start]
  local diffrz = clipa.zrot[iter] - clipa.zrot[clipa.start]
  aegisub.log(5,"cx: %f cy: %f\n",cx,cy)
  aegisub.log(5,"rx: %f ry: %f\n",ratx,raty)
  aegisub.log(5,"frz: %f\n",diffrz)
  local clip = ""
  local function xy(x,y)
    local xo,yo = x,y
    x = (tonumber(x) - clipa.xpos[clipa.start])*ratx
    y = (tonumber(y) - clipa.ypos[clipa.start])*raty
    local r = math.sqrt(x^2+y^2)
    local alpha = datan(y,x)
    x = cx + r*dcos(alpha-diffrz)
    y = cy + r*dsin(alpha-diffrz)
    aegisub.log(5,"Clip: %d %d -> %d %d\n",xo,yo,x,y)
    if line.sclip then 
      x = x*1024/(2^(line.sclip-1))
      y = y*1024/(2^(line.sclip-1))
    end
    return string.format("%d %d",round(x),round(y))
  end
  clip = line.clip:gsub("([%.%d%-]+) ([%.%d%-]+)",xy)
  if line.sclip then 
    clip = string.format("\\%s(11,%s)",line.clips,clip)
  else
    clip = string.format("\\%s(%s)",line.clips,clip)
  end
  return clip
end

function transformate(line,trans)
  local t_s = trans[1] - line.time_delta
  local t_e = trans[2] - line.time_delta
  aegisub.log(5,"Transform: %d,%d -> %d,%d\n",trans[1],trans[2],t_s,t_e)
  return line.text:gsub("\\t%b()","\\"..string.char(1)..string.format("t(%d,%d,%g,%s)",t_s,t_e,trans[3],trans[4]),1)
end

function scalify(scale,line,mocha,opts,tag)
  local newScale = scale*mocha.ratx -- sudden camelCase for no reason
  aegisub.log(5,"%s: %f -> %f\n",tag:sub(2),scale,newScale)
  return round(newScale,opts.sclround)
end

function VSscalify(scale,line,mocha,opts,tag)
  local newScale = round(scale*mocha.ratx,opts.sclround)
  local lowend, highend, decimal = math.floor(newScale),math.ceil(newScale),newScale%1*(10^opts.sclround)
  local start, send = -decimal, (10^opts.sclround)-decimal
  aegisub.log(5,"%s: %f -> %f\n",tag:sub(2),scale,newScale)
  return ("%d\\t(%d,%d,%s%d)"):format(lowend,start,send,tag,highend)
end

function rotate(rot,line,mocha,opts)
  local zrot = rot + mocha.zrotd
  aegisub.log(5,"frz: -> %f\n",zrot)
  return round(zrot,opts.rotround)
end

function munch(sub,sel)
  local changed = false
  for i,num in ipairs(sel) do
    if aegisub.progress.is_cancelled() then error("User cancelled") end
    local l1 = sub[num-1]
    local l2 = sub[num]
    if l1.text == l2.text and l1.effect == l2.effect then
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
    if tonumber(t_e) <= 0 then return string.format("%s",eff) end -- if the end time is less than or equal to zero, the transformation has finished. Replace it with only its contents.
    if tonumber(t_s) > linediff or tonumber(t_e) < tonumber(t_s) then return "" end -- if the start time is greater than the length of the line, the transform has not yet started, and can be removed from the line.
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

function table.tostring(t)
  if type(t) ~= 'table' then
    return tostring(t)
  else
    local s = ''
    local i = 1
    while t[i] ~= nil do
      if #s ~= 0 then s = s..', ' end
      s = s..table.tostring(t[i])
      i = i+1
    end
    for k, v in pairs(t) do
      if type(k) ~= 'number' or k > i then
        if #s ~= 0 then s = s..', ' end
        local key = type(k) == 'string' and k or '['..table.tostring(k)..']'
        s = s..key..'='..table.tostring(v)
      end
    end
    return '{'..s..'}'
  end
end

function isvideo() -- a very rudimentary (but hopefully efficient) check to see if there is a video loaded.
  local l = aegisub.video_size() and true or false -- and forces boolean conversion?
  if l then
    return l
  else
    return l,"Validation failed: you don't have a video loaded."
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
  local name = eff or accd.lines[1].actor or "Untitled"
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
  local valtab = {}
  local conf = configscope()
  if not readconf(conf,{ ['main'] = gui.conf; ['clip'] = gui.clip; ['global'] = global }) then aegisub.log(0,"Config read failed!\n") end
  for key, value in pairs(global) do
    gui.conf[key].value = value
  end
  local button, config = aegisub.dialog.display(gui.conf,{"Write","Write local","Clip...","Abort"})
  local clipconf
  if button == "Clip..." then
    button, clipconf = aegisub.dialog.display(gui.clip,{"Write","Write local","Cancel","Abort"})
  end
  if button == "Write" then
    local clipconf = clipconf or {}
    for key,value in pairs(global) do
      global[key] = config[key]
      config[key] = nil
    end
    for i,field in ipairs(guiconf.clip) do
      if clipconf[field] == nil then clipconf[field] = gui.clip[field].value end
    end 
    writeconf(conf,{ ['main'] = config; ['clip'] = clipconf; ['global'] = global })
  elseif button == "Write local" then
    local clipconf = clipconf or {}
    conf = aegisub.decode_path("?script/")..config_file
    for key,value in pairs(global) do
      global[key] = config[key]
      config[key] = nil
    end
    for i,field in ipairs(guiconf.clip) do
      if clipconf[field] == nil then clipconf[field] = gui.clip[field].value end
    end
    writeconf(conf,{ ['main'] = config; ['clip'] = clipconf; ['global'] = global })
  elseif button == "Cancel" then
    confmaker()
  else
    aegisub.cancel()
  end
end

if config_file then aegisub.register_macro("Motion Data - Config", "Full config management.", confmaker, isvideo) end

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

function collecttrim(sub,sel,tokens)
  tokens.startt, tokens.endt = sub[sel[1]].start_time, sub[sel[1]].end_time
  for i,v in ipairs(sel) do
    local l = sub[v]
    local lst, let = l.start_time, l.end_time
    if lst < tokens.startt then tokens.startt = lst end
    if let > tokens.endt then tokens.endt = let end
  end
  tokens.startf, tokens.endf = aegisub.frame_from_ms(tokens.startt), aegisub.frame_from_ms(tokens.endt)-1
  tokens.lenf = tokens.endf-tokens.startf+1
  tokens.lent = tokens.endt-tokens.startt
end
-- #{encbin} #{input} #{prefix} #{index} #{output} #{startf} #{lenf} #{endf} #{startt} #{lent} #{endt} #{nl}
function getvideoname(sub)
  for x = 1,#sub do
    if sub[x].key == "Video File" then
      return sub[x].value:sub(2)
    end
  end
end

function trimnthings(sub,sel)
  local conf = configscope()
  if conf then
    if not readconf(conf,{ ['global'] = global }) then aegisub.log(0,"Failed to read config!\n") end
  end
  local tokens = {}
  tokens.encbin = global.encbin
  tokens.prefix = global.prefix
  tokens.nl = "\n"
  collecttrim(sub,sel,tokens)
  local vid = getvideoname(sub):gsub("[A-Z]:\\",""):gsub(".-[^\\]\\","")
  assert(not vid:match("?dummy"), "No dummy videos allowed. Sorry.")
  tokens.input = aegisub.decode_path("?video")..vid
  tokens.index = vid:match("(.+)%.[^%.]+$")
  tokens.output = tokens.index -- huh.
  if not global.gui_trim then
    writeandencode(tokens)
  else
    someguiorsmth(tokens)
  end
end

function someguiorsmth(tokens)
  gui.t.input.value = tokens.input
  gui.t.index.value = tokens.index
  gui.t.startf.value = tokens.startf
  gui.t.endf.value = tokens.endf
  gui.t.output.value = tokens.output
  local button, opts = aegisub.dialog.display(gui.t)
  if button then
    for k,v in pairs(opts) do
      tokens[k] = v
    end
    tokens.startt, tokens.endt = aegisub.ms_from_frame(tokens.startf), aegisub.ms_from_frame(tokens.endf)
    tokens.lenf, tokens.lent = tokens.endf-tokens.startf, tokens.endt-tokens.startt
    writeandencode(tokens)
  end
end

function writeandencode(tokens)
  tokens.startt, tokens.endt, tokens.lent = tokens.startt/1000, tokens.endt/1000, tokens.lent/1000
  local function ReplaceTokens(token)
    return tokens[token:sub(2,-2)]
  end
  if global.windows then
    local sh = io.open(global.prefix.."encode.bat","w+")
    assert(sh,"Encoding command could not be written. Check your prefix.") -- to solve the 250 byte limit, we write to a self-deleting batch file.
    sh:write(global.enccom:gsub("#(%b{})",ReplaceTokens)..'\ndel %0')
    sh:close()
    os.execute(('""%s%s""'):format(global.prefix,"encode.bat")) -- double quotes makes it work on different drives too, apparently?
  else -- nfi what to do on lunix
    os.execute(global.enccom:gsub("#(%b{})",ReplaceTokens))
  end
end

aegisub.register_macro("Motion Data - Trim","Cuts and encodes the current scene for use with motion tracking software.", trimnthings, isvideo)