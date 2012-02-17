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
include("karaskel.lua")

gui = {} -- I'm really beginning to think this shouldn't be a global variable
gui.main = { -- todo: change these to be more descriptive.
  [1] = { class = "textbox"; -- 1 - because it is best if it starts out highlighted.
      x = 0; y = 1; height = 4; width = 10;
    name = "mocpat"; hint = "Paste data or the path to a file containing it. No quotes or escapes."},
  [2] = { class = "textbox";
      x = 0; y = 17; height = 4; width = 10;
    name = "preerr"; hint = "Any lines that might have problems are listed here."},
  [3] = { class = "textbox";
      x = 0; y = 14; height = 3; width = 10;
    name = "mocper"; hint = "The prefix"},
  [4] = { class = "label";
      x = 0; y = 13; height = 1; width = 10;
    label = "                     Files will be written to this directory."},
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
  [11] = { class = "checkbox";
      x = 2; y = 8; height = 1; width = 2;
    value = true; name = "bord"; label = "Border"},
  [12] = { class = "checkbox";
      x = 4; y = 8; height = 1; width = 2;
    value = true; name = "shad"; label = "Shadow"},
  [15] = { class = "checkbox";
      x = 0; y = 9; height = 1; width = 3;
    value = false; name = "rot"; label = "Rotation"},
  [16] = { class = "checkbox";
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
    value = false; name = "conf"; label = "Write config"},
  [21] = { class = "floatedit";
      x = 7; y = 11; height = 1; width = 3;
    value = 1; name = "xmult"},
  [22] = { class = "checkbox";
      x = 6; y = 11; height = 1; width = 1;
    value = 1; name = "ovr"},
  [23] = { class = "checkbox";
      x = 0; y = 12; height = 1; width = 3;
    value = false; name = "vsfilter"; label = "VSfilter scaling"},
  [24] = { class = "checkbox";
      x = 4; y = 12; height = 1; width = 2;
    value = false; name = "linear"; label = "Linear"},
  [25] = { class = "checkbox";
      x = 6; y = 12; height = 1; width = 2;
    value = false; name = "reverse"; label = "Reverse"},
  [26] = { class = "checkbox";
      x = 8; y = 12; height = 1; width = 2;
    value = false; name = "exp"; label = "Export"},
  [27] = { class = "dropdown"; 
      x = 5; y = 5; width = 4; height = 1;
      name = "sort"; hint = "Sort lines by"; 
     value = "Default"; items = {"Default", "Time"}}, 
  [28] = { class = "label";
      x = 1; y = 5; width = 4; height = 1;
    label = "      Sort Method:"},
}

for k,v in pairs(aegisub) do
  dpath = false
  if k == "decode_path" then
    dpath = true
    break
  end
end

if config_file == "" and dpath then config_file = aegisub.decode_path("?user/aegisub-motion.conf") end

global = {
  windows  = true,
  prefix   = "",
  x264     = "",
  x264op   = "--crf 16 --tune fastdecode -i 250 --fps 23.976",
  gui_trim = true,
  gnupauto = false,
}

header = {
  ['xscl'] = "scale_x",
  ['yscl'] = "scale_y",
  ['ali']  = "align",
  ['zrot'] = "angle",
  ['bord'] = "outline",
  ['shad'] = "shadow"
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
  ['yshad']   = "\\yshad([%-%d%.]+)"
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
  [8]  = "pos",
  [9]  = "clip",
  [10] = "scl",
  [11] = "bord",
  [12] = "shad",
  [15] = "rot",
  [16] = "org",
  [21] = "xmult",
  [22] = "ovr",
  [23] = "vsfilter",
  [24] = "linear",
  [25] = "reverse",
  [26] = "exp",
  [27] = "sort",
  [17] = "pround",
  [18] = "sround",
  [19] = "rround",
}

pi = 3.141592653589793238462643383279502884197169399375105821 -- so accurate~

function dcos(a) return math.cos(a*pi/180) end
function dsin(a) return math.sin(a*pi/180) end
function dtan(a) return math.tan(a*pi/180) end
function datan(a) return 180*math.atan(a)/pi end

fix = {}

fix.ali = {
  function(x,y,w,h,a) local r = w/2 return x+r*dcos(a)-h/2*dsin(a), y-r*dsin(a)-h/2*dcos(a) end;
  function(x,y,w,h,a) local r = h/2 return x-r*dsin(a), y-r*dcos(a) end;
  function(x,y,w,h,a) local r = w/2 return x-r*dcos(a)-h/2*dsin(a), y+r*dsin(a)-h/2*dcos(a) end;
  function(x,y,w,h,a) local r = w/2 return x+r*dcos(a), y-r*dsin(a) end;
  function(x,y,w,h,a) return x, y end;
  function(x,y,w,h,a) local r = w/2 return x-r*dcos(a), y+r*dsin(a) end;
  function(x,y,w,h,a) local r = w/2 return x+r*dcos(a)+h/2*dsin(a), y-r*dsin(a)+h/2*dcos(a) end;
  function(x,y,w,h,a) local r = h/2 return x+r*dsin(a), y+r*dcos(a) end;
  function(x,y,w,h,a) local r = w/2 return x-r*dcos(a)+h/2*dsin(a), y+r*dsin(a)+h/2*dcos(a) end;
}

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

function readconf(confpat) -- todo: MAKE THIS WORK WITHOUT CODE DUPLICATION HOLY FUCK I THINK I'M RETARDED
  local valtab = {}
  aegisub.log(5,"Opening config file: %s\n",confpat)
  local cf = io.open(confpat,'r')
  if cf then
    aegisub.log(5,"Reading config file...\n")
    for line in cf:lines() do
      local key, val = line:splitconf()
      aegisub.log(5,"Read: %s -> %s\n", key, tostring(val:tobool()))
      valtab[key] = val:tobool()
    end
    cf:close()
    convertfromconf(valtab)
    globalvars(valtab)
    return true
  else
    return nil
  end
end

function convertfromconf(valtab)
  for i,v in pairs(guiconf) do
    if valtab[v] ~= nil then
      aegisub.log(5,"Set: %s <- %s\n", v, tostring(valtab[v]))
      gui.main[i].value = valtab[v]
    else
      aegisub.log(5,"%s unset (nil value)\n", v)
    end
  end
end

function globalvars(valtab)
  for k,v in pairs(global) do
    if valtab[k] ~= nil then
      aegisub.log(5,"Set: %s <- %s\n",k,tostring(valtab[k]))
      global[k] = valtab[k]
    else
      aegisub.log(5,"%s unset (nil value)\n", k)
    end
  end
end

function writeconf(options)
  local cf = io.open(config_file,'w+')
  if not cf then 
    aegisub.log(0,'Config write failed! Check that %s exists and has write permission.\n',config_file)
    return nil
  end
  for k,v in pairs(global) do
    if v ~= nil then
      aegisub.log(5,"Conf <- %s:%s\n",k,tostring(v))
      cf:write(string.format("%s:%s\n",k,tostring(v)))
    end
  end
  for i,v in pairs(guiconf) do
    if options[v] ~= nil then
      aegisub.log(5,"Conf <- %s:%s\n",v,tostring(options[v]))
      cf:write(string.format("%s:%s\n",v,tostring(options[v])))
    end
  end
  cf:close()
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
      local fad_s,fad_e = a:match("\\fad%(([%d]+),([%d]+)%)") -- uint
      fad_s, fad_e = tonumber(fad_s), tonumber(fad_e)
      if fad_s then -- Swap out fade for a transform so we can stage it.
        line.text = line.text:gsub("\\fad%([%d]+,[%d]+%)",string.format("\\alpha&HFF&\\t(%d,%d,1,\\alpha&H00&)\\t(%d,%d,1,\\alpha&HFF&)",0,fad_s,length-fad_e,length))
      end
      local fade_a,fade_a2,fade_a3,fade_s,fade_m,fade_m2,fade_e = a:match("\\fade%(([%d]+),([%d]+),([%d]+),([%d]+),([%d]+),([%d]+),([%d]+)%)") -- I imagine this has never actually been tested
      if fade_a then
        line.text = line.text:gsub("\\fade%([%d]+,[%d]+,[%d]+,[%-%d]+,[%-%d]+,[%-%d]+,[%-%d]+%)",string.format("\\alpha&H%X&\\t(%d,%d,\\alpha&H%X&)\\t(%d,%d,\\alpha&H%X&)",fade_a,fade_s,fade_m,fade_a2,fade_m2,fade_3,fade_a3)) -- okay that wasn't actually so bad
      end
      local p1, p2 = a:match("\\move%(([%-%d%.]+),([%-%d%.]+),[%-%d%.]+,[%-%d%.]+,?[%-%d]*,?[%-%d]*%)")
    end
    sub[v] = line -- replace
  end
  return information(sub,sel) -- selected line numbers are the same
end

function getinfo(sub, line, styles, num)
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
    line.clips, line.clip = a:match("\\(i?clip%()([%-%d]+,[%-%d]+,[%-%d]+,[%-%d]+)%)") -- hum
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
  accd.vn = getvideoname(sub):gsub("[A-Z]:\\",""):gsub(".-[^\\]\\","")
  accd.lines = {}
  accd.endframe = aegisub.frame_from_ms(sub[sel[1]].end_time) -- get the end frame of the first selected line
  accd.startframe = aegisub.frame_from_ms(sub[sel[1]].start_time) -- get the start frame of the first selected line
  accd.poserrs, accd.alignerrs = {}, {}
  accd.errmsg = ""
  accd.shx, accd.shy = accd.meta.res_x, accd.meta.res_y
  local numlines = #sel
  for i, v in pairs(sel) do -- burning cpu cycles like they were no thing
    local opline = table.copy(sub[v]) -- I have no idea if a shallow copy is even an intelligent thing to do here
    opline.num = v -- for inserting lines later
    karaskel.preproc_line(sub, accd.meta, accd.styles, opline) -- get linewidth/height and margins
    if not opline.effect then opline.effect = "" end
    opline = getinfo(sub, opline, accd.styles, v-strt)
    opline.startframe, opline.endframe = aegisub.frame_from_ms(opline.start_time), aegisub.frame_from_ms(opline.end_time)
    if opline.comment then opline.is_comment = true else opline.is_comment = false end
    if not opline.xpos then
      opline.xpos = fix.xpos[opline.ali%3+1](accd.shx,opline.margin_l,opline.margin_r)
      opline.ypos = fix.ypos[math.ceil(opline.ali/3)](accd.shy,opline.margin_v)
      if opline.ali ~= 5 then
        if opline.xorg then
          local xd = opline.xpos - opline.xorg
          local yd = opline.ypos - opline.yorg
          local r = math.sqrt(xd^2+yd^2)
          local alpha = datan(yd/xd)
          opline.xpos = opline.xorg + r*dcos(alpha-opline.zrot)
          opline.ypos = opline.yorg + r*dsin(alpha-opline.zrot)
          opline.text = opline.text:gsub("\\org%(([%-%d%.]+),([%-%d%.]+)%)","")
        end
        opline.xpos,opline.ypos = fix.ali[opline.ali](opline.xpos,opline.ypos,opline.width*opline.xscl/100,opline.height*opline.yscl/100,opline.zrot)
        if v.ali ~= 5 then
          if v.text:match("\\an[1-9]") then
            v.text = v.text:gsub("\\an[1-9]","\\an5")
          else
            v.text = "{\\an5}"..string.char(6)..v.text
          end
        end
      end
    end
    if not opline.xorg then
      opline.xorg = opline.xpos
      opline.yorg = opline.ypos
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
  accd.toterrs = #accd.alignerrs + #accd.poserrs
  if accd.toterrs > 0 then
    accd.errmsg = "The lines noted below need to be checked.\n"..accd.errmsg
  else
    accd.errmsg = "None of the selected lines seem to be problematic.\n"..accd.errmsg 
  end
  assert(#accd.lines>0,"You have to select at least one line that is longer than one frame long.") -- pro error checking
  printmem("End of preproc loop")
  return accd
end

function init_input(sub,sel) -- THIS IS PROPRIETARY CODE YOU CANNOT LOOK AT IT
  aegisub.progress.title("Selecting Gerbils")
  local accd = preprocessing(sub,sel)
  if not (config_file:match("^[A-Z]:\\") or config_file:match("^/")) and dpath then
    aegisub.log(5,"herp\n")
    local cf = io.open(aegisub.decode_path("?script/"..config_file))
    if not cf then
      if not readconf(aegisub.decode_path("?user/"..config_file)) then accd.errmsg = "FAILED TO READ CONFIG\n"..accd.errmsg end
    else
      cf:close()
      readconf(aegisub.decode_path("?script/"..config_file))
    end
  else
    if not readconf(config_file) then accd.errmsg = "FAILED TO READ CONFIG\n"..accd.errmsg end
  end
  gui.main[2].value = accd.errmsg -- so close to being obsolete
  gui.main[3].value = global.prefix
  printmem("GUI startup")
  local button, config = aegisub.dialog.display(gui.main, {"Go","Abort","Export"})
  if button == "Go" then
    if config.reverse then
      aegisub.progress.title("slibreG gnicniM") -- BECAUSE ITS FUNNY GEDDIT
    else
      aegisub.progress.title("Mincing Gerbils")
    end
    if config.conf then
      writeconf(config)
    end
    printmem("Go")
    local newsel = frame_by_frame(sub,accd,config)
    aegisub.progress.title("Reformatting Gerbils")
    cleanup(sub,newsel,config)
  elseif button == "Export" then
    export(accd,parse_input(config.mocpat,accd.shx,accd.shy),config)
  else
    aegisub.progress.task("ABORT")
    if dpath then aegisub.cancel() end
  end
  aegisub.set_undo_point("Motion Data")
  printmem("Closing")
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
  assert(mocha.flength == #mocha.ypos and mocha.flength == #mocha.xscl and mocha.flength == #mocha.yscl and mocha.flength == #mocha.zrot,"The mocha data is not internally equal length.") -- make sure all of the elements are the same length (because I don't trust my own code).
  printmem("End of input parsing")
  return mocha -- hurr durr
end

function frame_by_frame(sub,accd,opts)
  printmem("Start of main loop")
  local mocha = parse_input(opts.mocpat,accd.shx,accd.shy) -- global variables have no automatic gc
  assert(accd.totframes==mocha.flength,"Number of frames from selected lines differs from number of frames tracked.")
  if opts.exp then export(accd,mocha,opts) end
  for k,v in ipairs(accd.lines) do -- comment lines that were commented in the thingy
    local derp = sub[v.num]
    derp.comment = true
    derp.effect = "aa-mou"..derp.effect
    sub[v.num] = derp
    if not v.is_comment then v.comment = false end
  end
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
    opts.sround = 2
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
          if not v.is_comment then
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
    --aegisub.log(5,"%s\n",tostring(sub[x].effect))
    if tostring(sub[x].effect):match("^aa%-mou") then -- I wonder if a second if 
      aegisub.log(5,"I choose you, %d!\n",x)
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
  aegisub.log(5,"Position: (%f,%f) -> (%f,%f)\n",line.xpos,line.ypos,xpos,ypos)
  local nf = string.format("%%.%df",opts.pround) -- new method of number formatting!
  return "\\pos("..string.format(nf,xpos)..","..string.format(nf,ypos)..")"
end

--[[ 
   How it seems to work (based on 30 seconds of research):
    For \\clip(%d,%d,%d,%d), libass will round to the nearest integer (5-> up 4-> down).
     VSfilter will floor the value (ignore the decimal point) as it does with other tags
     that it only accepts integer values for.
    For a vector clip, libass will again round all decimal values to the nearest integer.
     VSfilter will break parsing as soon as it hits a decimal point, ignoring all numbers
     that come after the decimal point, and treating any digits that lead up to it as the
     whole number (e.g. 350.5 -> 350). Come to think of it, this is probably how it handles
     all of the tags it can only read integer values from.
  ]]--
function clippinate(line,mocha,opts,iter)
  if line.clip then
    local xpos = mocha.xpos[iter]-(line.xdiff*line.ratx) -- allocating memory like a bawss
    local ypos = mocha.ypos[iter]-(line.ydiff*line.raty)
    local switch = 0
    local newvals = {}
    local newclip = line.clip
    local function xy(x,y)
      local xo,yo = x,y
      x = xpos + (tonumber(x) - line.xpos)*line.xscl*line.ratx/100
      y = ypos + (tonumber(y) - line.ypos)*line.yscl*line.raty/100
      aegisub.log(5,"Clip: %d %d -> %d %d",xo,yo,x,y)
      if line.sclip then x = x*1024/(2^(line.sclip-1)) end
      if line.sclip then y = y*1024/(2^(line.sclip-1)) end
      table.insert(newvals,round(x).." "..round(y))
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
      return string.format("\\%s(11,%s)",line.clips,newclip)
    else
      return string.format("\\%s(%s)",line.clips,newclip)
    end
  else return "" end
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
  return string.format("\\fscx%g\\fscy%g",round(xscl,opts.sround),round(yscl,opts.sround))
end

function bordicate(line,mocha,opts)
  local xbord = line.xbord*round(line.ratx,opts.sround) -- round beforehand to minimize random float errors
  local ybord = line.ybord*round(line.raty,opts.sround) -- or maybe that's rly fucking dumb? idklol
  if xbord == ybord then
    aegisub.log(5,"Border: %f -> %f",line.xbord,xbord)
    return string.format("\\bord%g",round(xbord,opts.sround))
  else
    aegisub.log(5,"XBorder: %f -> %f",line.xbord,xbord)
    aegisub.log(5,"YBorder: %f -> %f",line.ybord,ybord)
    return string.format("\\xbord%g\\ybord%g",round(xbord,opts.sround),round(ybord,opts.sround))
  end
end

function shadinate(line,mocha,opts)
  local xshad = line.xshad*round(line.ratx,opts.sround) -- scale shadow the same way as everything else
  local yshad = line.yshad*round(line.raty,opts.sround) -- hope it turns out as desired
  if xshad == yshad then
    aegisub.log(5,"Shadow: %f -> %f",line.xshad,xshad)
    return string.format("\\shad%g",round(xshad,opts.sround))
  else
    aegisub.log(5,"XShadow: %f -> %f",line.xshad,xshad)
    aegisub.log(5,"YShadow: %f -> %f",line.yshad,yshad)
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
  local zrot = mocha.zrot[iter]-line.zrotd
  aegisub.log(5,"ZRotation: -> %f",zrot)
  return string.format("\\frz%g",round(zrot,opts.rround)) -- copypasta
end

function orgate(line,mocha,opts,iter)
  local xorg = mocha.xpos[iter]
  local yorg = mocha.ypos[iter]
  aegisub.log(5,"Origin: -> (%f,%f)",xorg,yorg)
  return string.format("\\org(%g,%g)",round(xorg,opts.rround),round(yorg,opts.rround)) -- copypasta
end

function cleanup(sub, sel, opts) -- make into its own macro eventually.
  local linediff
  function cleantrans(cont) -- internal function because that's the only way to pass the line difference to it
    local t_s, t_e, ex, eff = cont:sub(2,-2):match("([%-%d]+),([%-%d]+),([%d%.]*),?(.+)")
    if tonumber(t_e) <= 0 or tonumber(t_e) <= tonumber(t_s) then return string.format("%s",eff) end -- if the end time is less than or equal to zero, the transformation has finished. Replace it with only its contents.
    if tonumber(t_s) > linediff then return "" end -- if the start time is greater than the length of the line, the transform has not yet started, and can be removed from the line.
    if tonumber(ex) == 1 or ex == "" then return string.format("\\t(%s,%s,%s)",t_s,t_e,eff) end -- if the exponential factor is equal to 1 or isn't there, remove it (just makes it look cleaner)
    return string.format("\\t(%s,%s,%s,%s)",t_s,t_e,ex,eff) -- otherwise, return an untouched transform.
  end
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
  if opts.sort ~= "Default" then
    dialog_sort(sub, sel, opts.sort)
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
    ['Time'] = function(l,n) return { key = l.start_time, num = n, data = l } end;
    --[[ These are pretty pointless since they should all end up in the same order as "Default"
    ['Actor'] = function(l,n) return { key = l.actor, num = n, data = l } end;
    ['Effect'] = function(l,n) return { key = l.effect, num = n, data = l } end;
    ['Style'] = function(l,n) return { key = l.style, num = n, data = l } end;
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
  for i, v in ipairs(lines) do
    if aegisub.progress.is_cancelled() then error("User cancelled") end
    aegisub.progress.title(string.format("Sorting gerbils: %d/%d",i,#lines))
    aegisub.progress.set(i/#lines*100) 
    aegisub.log(5,"Key: "..v.key..'\n')
    aegisub.progress.set(i/#lines*100)
    sub.insert(strt+i-1,v.data) -- not sure this is the best place to do this but owell
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

aegisub.register_macro("Apply motion data", "Applies properly formatted motion tracking data to selected subtitles.", init_input, isvideo)

function export(accd,mocha,opts)
  local fnames = {}
  if opts.pos then
    fnames[1] = "%s X-Y %d-%d.txt"
    fnames[2] = "%s T-X %d-%d.txt"
    fnames[3] = "%s T-Y %d-%d.txt"
  end
  if opts.scl then
    fnames[4] = "%s T-sclX %d-%d.txt"
    fnames[5] = "%s T-sclY %d-%d.txt"
  end
  if opts.rot then
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
  if opts.pos then
    table.insert(bigstring,string.format([=[set terminal png small transparent truecolor size %d,%d; set output '%s.png']=]..'\n',accd.shx+70,accd.shy+80,global.prefix..fnames[1]:sub(0,-5)))
    table.insert(bigstring,string.format([=[set title 'Plot of X vs Y']=]..'\n'))
    table.insert(bigstring,string.format([=[unset xtics; set x2tics out mirror; set mx2tics 5; set x2label 'X Position (Pixels)'; set xrange [0:%d]]=]..'\n',accd.shx))
    table.insert(bigstring,string.format([=[set ytics out; set mytics 5; set ylabel 'Y Position (Pixels)'; set yrange [0:%d] reverse]=]..'\n',accd.shy))
    table.insert(bigstring,string.format([=[set grid x2tics mx2tics mytics ytics; stats '%s' using 1:2 name 'XvYstat']=]..'\n',global.prefix..fnames[1]))
    table.insert(bigstring,string.format([=[f(x) = m*x + b; fit f(x) '%s' using 1:2 via m,b]=]..'\n',global.prefix..fnames[1]))
    table.insert(bigstring,string.format([=[if (b >= 0) slope = sprintf('y(x) = %%.3fx + %%.3f : R^2: %%.3f',m,b,XvYstat_correlation**2); else slope = sprintf('y(x) = %%.3fx - %%.3f : R^2: %%.3f',m,0-b,XvYstat_correlation**2)]=]..'\n'))
    table.insert(bigstring,string.format([=[plot '%s' using 1:2 notitle with points, f(x) title slope with lines]=]..'\n',global.prefix..fnames[1]))

    table.insert(bigstring,string.format('\n'..[=[set terminal png small transparent truecolor size %d,%d; set output '%s.png']=]..'\n',round(len*2+70,0),accd.shx+80,global.prefix..fnames[2]:sub(0,-5)))
    table.insert(bigstring,string.format([=[set title 'Plot of T vs X'; unset x2label]=]..'\n'))
    table.insert(bigstring,string.format([=[unset x2tics; unset mx2tics; set xtics out mirror; set mxtics 5; set xlabel 'Time (centiseconds)'; set xrange [0:%d]]=]..'\n',round(len,0)))
    table.insert(bigstring,string.format([=[set ytics out; set mytics 5; set ylabel 'X Position (Pixels)'; set yrange [0:%d] reverse]=]..'\n',accd.shx))
    table.insert(bigstring,string.format([=[set grid xtics mxtics ytics mytics; stats '%s' using 1:2 name 'TvXstat']=]..'\n',global.prefix..fnames[2]))
    table.insert(bigstring,string.format([=[f(x) = m*x + b; fit f(x) '%s' using 1:2 via m,b]=]..'\n',global.prefix..fnames[2]))
    table.insert(bigstring,string.format([=[if (b >= 0) slope = sprintf('Equation: x(t) = %%.3ft + %%.3f : R^2: %%.3f',m,b,TvXstat_correlation**2); else slope = sprintf('Equation: x(t) = %%.3ft - %%.3f : R^2: %%.3f',m,0-b,TvXstat_correlation**2)]=]..'\n'))
    table.insert(bigstring,string.format([=[plot '%s' using 1:2 notitle with points, f(x) title slope with lines]=]..'\n',global.prefix..fnames[2]))

    table.insert(bigstring,string.format('\n'..[=[set terminal png small transparent truecolor size %d,%d; set output '%s.png']=]..'\n',round(len*2+70,0),accd.shx+80,global.prefix..fnames[3]:sub(0,-5)))
    table.insert(bigstring,string.format([=[set title 'Plot of T vs Y'; unset x2label]=]..'\n'))
    table.insert(bigstring,string.format([=[unset x2tics; unset mx2tics; set xtics out mirror; set mxtics 5; set xlabel 'Time (centiseconds)'; set xrange [0:%d]]=]..'\n',round(len,0)))
    table.insert(bigstring,string.format([=[set ytics out; set mytics 5; set ylabel 'Y Position (Pixels)'; set yrange [0:%d] reverse]=]..'\n',accd.shy))
    table.insert(bigstring,string.format([=[set grid xtics mxtics ytics mytics; stats '%s' using 1:2 name 'TvYstat']=]..'\n',global.prefix..fnames[3]))
    table.insert(bigstring,string.format([=[f(x) = m*x + b; fit f(x) '%s' using 1:2 via m,b]=]..'\n',global.prefix..fnames[3]))
    table.insert(bigstring,string.format([=[if (b >= 0) slope = sprintf('Equation: y(t) = %%.3ft + %%.3f : R^2: %%.3f',m,b,TvYstat_correlation**2); else slope = sprintf('Equation: y(t) = %%.3ft - %%.3f : R^2: %%.3f',m,0-b,TvYstat_correlation**2)]=]..'\n'))
    table.insert(bigstring,string.format([=[plot '%s' using 1:2 notitle with points, f(x) title slope with lines]=]..'\n',global.prefix..fnames[3]))
  end
  if opts.scl then
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
  if opts.rot then
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
    if opts.pos then
      fhandle[1]:write(string.format("%g %g\n",mocha.xpos[x],mocha.ypos[x]))
      fhandle[2]:write(string.format("%g %g\n",cs,mocha.xpos[x]))
      fhandle[3]:write(string.format("%g %g\n",cs,mocha.ypos[x]))
    end
    if opts.scl then
      fhandle[4]:write(string.format("%g %g\n",cs,mocha.xscl[x]))
      fhandle[5]:write(string.format("%g %g\n",cs,mocha.yscl[x]))
    end
    if opts.rot then
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
  newgui[5].label = "         Enter the path to your prefix here (include trailing slash)."
  newgui[4].label = "              First box: path to x264; second box: x264 options."
  newgui["windows"] = {  class = "checkbox"; -- there's probably a reason for this.
      x = 0; y = 21; height = 1; width = 3;
    value = global.windows; name = "windows"; label = "I'm on Windows"}
  newgui["gui_trim"] = {  class = "checkbox";
      x = 3; y = 21; height = 1; width = 4;
    value = global.gui_trim; name = "gui_trim"; label = "Enable trim GUI"}
  newgui["gnupauto"] = {  class = "checkbox";
      x = 7; y = 21; height = 1; width = 3;
    value = global.gui_expo; name = "gnupauto"; label = "Autoplot exports"}
  newgui["prefix"] = table.copy_deep(newgui[1])
  newgui["x264"] = table.copy_deep(newgui[3])
  newgui["x264op"] = table.copy_deep(newgui[2])
  newgui[1], newgui[2], newgui[3] = nil, nil, nil
  newgui.prefix.name = "prefix"
  newgui["prefix"].value = global.prefix
  newgui.x264.name = "x264"
  newgui["x264"].value = global.x264
  newgui.x264op.name = "x264op"
  newgui["x264op"].value = global.x264op
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
  local conf = io.open(cf) -- there is probably a less terrible way to do this.
  if conf then
    aegisub.log(5,"Reading config file...\n")
    for line in conf:lines() do
      local key, val = line:splitconf()
      aegisub.log(5,"Read: %s -> %s\n", key, tostring(val:tobool()))
      valtab[key] = val:tobool()
    end
    for i,v in pairs(guiconf) do
      if valtab[v] ~= nil then
        aegisub.log(5,"Set: %s <- %s\n", v, tostring(valtab[v]))
        newgui[i].value = valtab[v]
      end
    end
    for k,v in pairs(global) do
      if valtab[k] ~= nil then
        aegisub.log(5,"Set: %s <- %s\n", k, tostring(valtab[k]))
        newgui[k].value = valtab[k]
      end
    end
  else
    aegisub.log(0,"Config read failed!")
  end
  local button, config = aegisub.dialog.display(newgui)
  if button then writeconf2(cf,config) end
end

function writeconf2(config,options)
  local cf = io.open(config,'w+')
  if not cf then 
    aegisub.log(0,'Config write failed! Check that %s exists and has write permission.\n',config_file)
    return nil
  end
  for k,v in pairs(global) do
    if options[k] ~= nil then
      aegisub.log(5,"Write: %s:%s -> conf\n",k,tostring(options[k]))
      cf:write(string.format("%s:%s\n",k,tostring(options[k])))
    end
  end
  for i,v in pairs(guiconf) do
    if options[v] ~= nil then
      aegisub.log(5,"Write: %s:%s -> conf\n",v,tostring(options[v]))
      cf:write(string.format("%s:%s\n",v,tostring(options[v])))
    end
  end
  cf:close()
end

aegisub.register_macro("Edit Config", "Macro for full config editing.", confmaker, isvideo)

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
  if not readconf() then aegisub.log(0,"Failed to read config!\n") end
  local video = ""
  local vp
  local vn
  local sf,ef = collecttrim(sub,sel)
  if dpath then
    video = getvideoname(sub)
    assert(not video:match("?dummy"), "No dummy videos allowed. Sorry.")
    video = video:gsub("[A-Z]:\\",""):gsub(".-[^\\]\\","")
    if dpath then vp = aegisub.decode_path("?video")..video else vp = video end-- the name of the video appended to the video path from aegisub.
    vn = video:match("(.+)%.[^%.]+$") -- the name of the video, with its extension removed. This expression is sketchy.
  end
  if dpath and not global.gui_trim then 
    local tabae = { ['vid'] = vp, ['sf'] = sf, ['ef'] = ef, ['ind'] = global.prefix..vn..".index", ['op'] = global.prefix..vn.."-"..sf.."-%d.mp4"}
    writeandencode(tabae)
  else
    someguiorsmth(sf,ef,vp,vn,sub[sel[1]])
  end
end

function someguiorsmth(sf,ef,vp,vn,line)
  gui.t[1].value = vp
  gui.t[2].value = global.prefix..vn..".index"
  gui.t[3].value = sf
  gui.t[4].value = ef
  gui.t[5].value = global.prefix..(line.effect or vn).."-"..sf.."-%d.mp4"
  local button, opts = aegisub.dialog.display(gui.t)
  if button then 
    writeandencode(opts)
  end
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
  if global.windows then
    local sh = io.open(global.prefix.."encode.bat","w+")
    if not sh then error("Encoding command could not be written. Check your prefix.") end -- to solve the 250 char limit, we write to a self-deleting batch file on windows.
    sh:write(global.x264..' '..global.x264op..' --index "'..opts.ind..'" --seek '..opts.sf..' --frames '..(opts.ef-opts.sf+1)..' -o "'..out..'" "'..opts.vid..'"\ndel %0')
    sh:close()
    os.execute(global.prefix.."encode.bat")
  else -- nfi what to do on lunix: dunno if it will allow execution of a shell script without explicitly setting the permissions. "x264 `cat x264opts.txt`" perhaps
    os.execute(global.x264..' '..global.x264op..' --index "'..opts.ind..'" --seek '..opts.sf..' --frames '..(opts.ef-opts.sf+1)..' -o "'..out..'" "'..opts.vid..'"')
  end
 end

aegisub.register_macro("Cut scene for mocha","Cuts and encodes the current scene for use with motion tracking software.", trimnthings, isvideo)