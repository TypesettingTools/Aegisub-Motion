local log, Transform
version = '1.3.4'

haveDepCtrl, DependencyControl = pcall require, 'l0.DependencyControl'

if haveDepCtrl
	version = DependencyControl {
		name: 'Tags'
		:version
		description: 'A mess for manipulating tags.'
		author: 'torque'
		url: 'https://github.com/TypesettingTools/Aegisub-Motion'
		moduleName: 'a-mo.Tags'
		feed: 'https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json'
		{
			{ 'a-mo.Log',       version: '1.0.0'       }
			{ 'a-mo.Transform', version: '1.2.3' }
		}
	}
	log, Transform = version\requireModules!

else
	log = require 'a-mo.Log'

-- In the following conversion functions, self refers to the tag table.
convertStringValue = ( value ) =>
	return value

convertNumberValue = ( value ) =>
	return tonumber value

convertHexValue = ( value ) =>
	return tonumber value, 16

convertColorValue = ( value ) =>
	output = { }
	for i = 1, 5, 2
		table.insert output, tonumber value\sub( i, i+1 ), 16
	output.r = output[3]
	output.b = output[1]
	output.g = output[2]
	return output

convertKaraoke = ( ... ) =>
	args = {...}
	@tag = args[1]
	return tonumber args[2]

-- This doesn't actually work with vector clips but i dont care.
convertMultiValue = ( value ) =>
	output = { }
	value\gsub "[%.%d%-]+", ( coord ) ->
		table.insert output, coord

	for index = 1, #@fieldnames
		output[@fieldnames[index]] = output[index]

	return output

convertTransformValue = ( value ) =>
	-- awkwardly solve circular require.
	Transform = Transform or require 'a-mo.Transform'
	return Transform\fromString value

interpolateNumber = ( before, after, progress ) =>
	return (1 - progress)*before + progress*after

interpolateMulti = ( before, after, progress ) =>
	result = { }
	for index = 1, #@fieldnames
		key = @fieldnames[index]
		result[index] = interpolateNumber @, before[index], after[index], progress
		result[key]   = result[index]

	return result

interpolatePosition = ( before, after, progress ) =>
	return {
		interpolateNumber @, before[1], after[1], progress
		interpolateNumber @, before[2], after[2], progress
	}

interpolateColor = ( before, after, progress ) =>
	return interpolateMulti { fieldnames: { 'b', 'g', 'r' } }, before, after, progress

formatString = ( value ) =>
	return @tag .. value

formatInt = ( value ) =>
	return ("%s%d")\format @tag, value

formatFloat = ( value ) =>
	return ("%s%g")\format @tag, value

formatAlpha = ( alpha ) =>
	return ("%s&H%02X&")\format @tag, alpha

formatColor = ( color ) =>
	return ("%s&H%02X%02X%02X&")\format @tag, color.b, color.g, color.r

formatKaraoke = ( time ) =>
	result = ("%s%d")\format @tag, time
	return result

formatTransform = ( transform ) =>
	return transform\toString!

formatMulti = ( value ) =>
	return ("%s(%s)")\format @tag, table.concat value, ','

allTags = {
	fontName: { pattern: "\\fn([^\\}]+)"     , tag: "\\fn"   , format: formatString, style: "fontname"                      , convert: convertStringValue                                 }
	fontSize: { pattern: "\\fs(%d+)"         , tag: "\\fs"   , format: formatInt   , style: "fontsize", transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	fontSp:   { pattern: "\\fsp([%.%d%-]+)"  , tag: "\\fsp"  , format: formatFloat , style: "spacing" , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	xscale:   { pattern: "\\fscx([%d%.]+)"   , tag: "\\fscx" , format: formatFloat , style: "scale_x" , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	yscale:   { pattern: "\\fscy([%d%.]+)"   , tag: "\\fscy" , format: formatFloat , style: "scale_y" , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	zrot:     { pattern: "\\frz?([%-%d%.]+)" , tag: "\\frz"  , format: formatFloat , style: "angle"   , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	xrot:     { pattern: "\\frx([%-%d%.]+)"  , tag: "\\frx"  , format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	yrot:     { pattern: "\\fry([%-%d%.]+)"  , tag: "\\fry"  , format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	border:   { pattern: "\\bord([%d%.]+)"   , tag: "\\bord" , format: formatFloat , style: "outline" , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	xborder:  { pattern: "\\xbord([%d%.]+)"  , tag: "\\xbord", format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	yborder:  { pattern: "\\ybord([%d%.]+)"  , tag: "\\ybord", format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	shadow:   { pattern: "\\shad([%-%d%.]+)" , tag: "\\shad" , format: formatFloat , style: "shadow"  , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	xshadow:  { pattern: "\\xshad([%-%d%.]+)", tag: "\\xshad", format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	yshadow:  { pattern: "\\yshad([%-%d%.]+)", tag: "\\yshad", format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	reset:    { pattern: "\\r([^\\}]*)"      , tag: "\\r"    , format: formatString                                         , convert: convertStringValue                                 }
	alpha:    { pattern: "\\alpha&H(%x%x)&"  , tag: "\\alpha", format: formatAlpha                    , transformable: true , convert: convertHexValue   , interpolate: interpolateNumber, type: "alpha" }
	alpha1:   { pattern: "\\1a&H(%x%x)&"     , tag: "\\1a"   , format: formatAlpha , style: "color1"  , transformable: true , convert: convertHexValue   , interpolate: interpolateNumber, type: "alpha", affectedBy: { "alpha" } }
	alpha2:   { pattern: "\\2a&H(%x%x)&"     , tag: "\\2a"   , format: formatAlpha , style: "color2"  , transformable: true , convert: convertHexValue   , interpolate: interpolateNumber, type: "alpha", affectedBy: { "alpha" } }
	alpha3:   { pattern: "\\3a&H(%x%x)&"     , tag: "\\3a"   , format: formatAlpha , style: "color3"  , transformable: true , convert: convertHexValue   , interpolate: interpolateNumber, type: "alpha", affectedBy: { "alpha" } }
	alpha4:   { pattern: "\\4a&H(%x%x)&"     , tag: "\\4a"   , format: formatAlpha , style: "color4"  , transformable: true , convert: convertHexValue   , interpolate: interpolateNumber, type: "alpha", affectedBy: { "alpha" } }
	color1:   { pattern: "\\1?c&H(%x+)&"     , tag: "\\1c"   , format: formatColor , style: "color1"  , transformable: true , convert: convertColorValue , interpolate: interpolateColor , type: "color" }
	color2:   { pattern: "\\2c&H(%x+)&"      , tag: "\\2c"   , format: formatColor , style: "color2"  , transformable: true , convert: convertColorValue , interpolate: interpolateColor , type: "color" }
	color3:   { pattern: "\\3c&H(%x+)&"      , tag: "\\3c"   , format: formatColor , style: "color3"  , transformable: true , convert: convertColorValue , interpolate: interpolateColor , type: "color" }
	color4:   { pattern: "\\4c&H(%x+)&"      , tag: "\\4c"   , format: formatColor , style: "color4"  , transformable: true , convert: convertColorValue , interpolate: interpolateColor , type: "color" }
	be:       { pattern: "\\be([%d%.]+)"     , tag: "\\be"   , format: formatInt                      , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	blur:     { pattern: "\\blur([%d%.]+)"   , tag: "\\blur" , format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	xshear:   { pattern: "\\fax([%-%d%.]+)"  , tag: "\\fax"  , format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	yshear:   { pattern: "\\fay([%-%d%.]+)"  , tag: "\\fay"  , format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
	align:    { pattern: "\\an([1-9])"       , tag: "\\an"   , format: formatInt   , style: "align"                         , convert: convertNumberValue                                , global: true }
	-- bold, italic, underline and strikeout are actually stored in the style table as boolean values.
	bold:     { pattern: "\\b(%d+)"          , tag: "\\b"    , format: formatInt   , style: "bold"                          , convert: convertNumberValue }
	underline:{ pattern: "\\u([01])"         , tag: "\\u"    , format: formatInt   , style: "underline"                     , convert: convertNumberValue }
	italic:   { pattern: "\\i([01])"         , tag: "\\i"    , format: formatInt   , style: "italic"                        , convert: convertNumberValue }
	strike:   { pattern: "\\s([01])"         , tag: "\\s"    , format: formatInt   , style: "strikeout"                     , convert: convertNumberValue }
	drawing:  { pattern: "\\p(%d+)"          , tag: "\\p"    , format: formatInt                                            , convert: convertNumberValue    }
	transform:{ pattern: "\\t(%(.-%))"       , tag: "\\t"    , format: formatTransform                                      , convert: convertTransformValue }
	karaoke:  { pattern: "(\\[kK][fo]?)(%d+)"                , format: formatInt                                            , convert: convertKaraoke }
	-- Problematic tags:
	pos:      { fieldnames: { "x", "y" }        , output: "multi", pattern: "\\pos%(([%.%d%-]+,[%.%d%-]+)%)", tag: "\\pos"  , format: formatMulti, convert: convertMultiValue, global: true }
	org:      { fieldnames: { "x", "y" }        , output: "multi", pattern: "\\org%(([%.%d%-]+,[%.%d%-]+)%)", tag: "\\org"  , format: formatMulti, convert: convertMultiValue, global: true }
	fad:      { fieldnames: { "in", "out" }     , output: "multi", pattern: "\\fade?%((%d+,%d+)%)"          , tag: "\\fad"  , format: formatMulti, convert: convertMultiValue, global: true }
	vectClip: { fieldnames: { "scale", "shape" }, output: "multi", pattern: "\\clip%((%d+,)?([^,]-)%)"      , tag: "\\clip" , format: formatMulti, convert: convertMultiValue, global: true }
	vectiClip:{ fieldnames: { "scale", "shape" }, output: "multi", pattern: "\\iclip%((%d+,)?([^,]-)%)"     , tag: "\\iclip", format: formatMulti, convert: convertMultiValue, global: true }
	rectClip: { fieldnames: { "xLeft", "yTop", "xRight", "yBottom" }    , output: "multi", pattern: "\\clip%(([%-%d%.]+,[%-%d%.]+,[%-%d%.]+,[%-%d%.]+)%)?" , transformable: true, tag: "\\clip" , format: formatMulti, convert: convertMultiValue, interpolate: interpolateMulti,    global: true }
	rectiClip:{ fieldnames: { "xLeft", "yTop", "xRight", "yBottom" }    , output: "multi", pattern: "\\iclip%(([%-%d%.]+,[%-%d%.]+,[%-%d%.]+,[%-%d%.]+)%)?", transformable: true, tag: "\\iclip", format: formatMulti, convert: convertMultiValue, interpolate: interpolateMulti,    global: true }
	move:     { fieldnames: { "x1", "y1", "x2", "y2", "start", "end" }  , output: "multi", pattern: "\\move%(([%.%d%-]+,[%.%d%-]+,[%.%d%-]+,[%.%d%-]+,[%d%-]+,[%d%-]+)%)"       , tag: "\\move" , format: formatMulti, convert: convertMultiValue, interpolate: interpolatePosition, global: true }
	fade:     { fieldnames: { "a1", "a2", "a3", "t1", "t2", "t3", "t4" }, output: "multi", pattern: "\\fade%((%d+,%d+,%d+,[%d%-]+,[%d%-]+,[%d%-]+,[%d%-]+)%)"                   , tag: "\\fade" , format: formatMulti, convert: convertMultiValue, global: true }
}

repeatTags = { }
oneTimeTags = { }
styleTags = { }
transformTags = { }

for k, v in pairs allTags
	v.name = k
	unless v.global
		table.insert repeatTags, v
	else
		table.insert oneTimeTags, v

	if v.style
		table.insert styleTags, v

	if v.transformable
		table.insert transformTags, v

tags = {
	:version

	:repeatTags
	:oneTimeTags
	:styleTags
	:transformTags

	:allTags
}

if haveDepCtrl
	return version\register tags
else
	return tags
