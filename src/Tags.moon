log = require 'a-mo.Log'
local Transform

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

interpolateColor = ( before, after, progress ) =>
	return interpolateMulti { fieldnames: { 'b', 'g', 'r' } }, before, after, progress

formatString = ( value ) =>
	return @tag .. value

formatInt = ( value ) =>
	return ("%s%d")\format @tag, value

formatFloat = ( value ) =>
	return ("%s%g")\format @tag, value

formatAlpha = ( alpha ) =>
	return ("%s&H%02X&")\format @tag, value

formatColor = ( color ) =>
	return ("%s&H%02X%02X%02X&")\format @tag, color.b, color.g, color.r

formatTransform = ( transform ) =>
	return transform\toString!

formatMulti = ( value ) =>
	return ("%s(%s)")\format @tag, table.concat value, ','

return {
	repeatTags: {
		"fontName", "fontSize", "fontSp", "xscale", "yscale", "zrot", "xrot", "yrot", "border", "xborder", "yborder", "shadow", "xshadow", "yshadow", "reset", "alpha", "alpha1", "alpha2", "alpha3", "alpha4", "color1", "color2", "color3", "color4", "be", "blur", "xshear", "yshear", "drawing"
	}

	oneTimeTags: {
		"align", "pos", "move", "org", "fad", "fade", "rectClip", "rectiClip", "vectClip", "vectiClip"
	}

	allTags: {
		fontName: { pattern: "\\fn([^\\}]+)"     , tag: "\\fn"   , format: formatString, style: "fontname"                      , convert: convertStringValue                                 }
		fontSize: { pattern: "\\fs(%d+)"         , tag: "\\fs"   , format: formatInt   , style: "fontsize", transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		fontSp:   { pattern: "\\fsp([%.%d%-]+)"  , tag: "\\fsp"  , format: formatFloat , style: "spacing" , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		xscale:   { pattern: "\\fscx([%d%.]+)"   , tag: "\\fscx" , format: formatFloat , style: "scale_x" , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		yscale:   { pattern: "\\fscy([%d%.]+)"   , tag: "\\fscx" , format: formatFloat , style: "scale_y" , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		zrot:     { pattern: "\\frz?([%-%d%.]+)" , tag: "\\frz"  , format: formatFloat , style: "angle"   , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		xrot:     { pattern: "\\frx([%-%d%.]+)"  , tag: "\\frx"  , format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		yrot:     { pattern: "\\fry([%-%d%.]+)"  , tag: "\\fry"  , format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		border:   { pattern: "\\bord([%d%.]+)"   , tag: "\\bord" , format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		xborder:  { pattern: "\\xbord([%d%.]+)"  , tag: "\\xbord", format: formatFloat , style: "outline" , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		yborder:  { pattern: "\\ybord([%d%.]+)"  , tag: "\\ybord", format: formatFloat , style: "outline" , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		shadow:   { pattern: "\\shad([%-%d%.]+)" , tag: "\\shad" , format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		xshadow:  { pattern: "\\xshad([%-%d%.]+)", tag: "\\xshad", format: formatFloat , style: "shadow"  , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		yshadow:  { pattern: "\\yshad([%-%d%.]+)", tag: "\\yshad", format: formatFloat , style: "shadow"  , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		reset:    { pattern: "\\r([^\\}]*)"      , tag: "\\r"    , format: formatString                                         , convert: convertStringValue                                 }
		alpha:    { pattern: "\\alpha&H(%x%x)&"  , tag: "\\alpha", format: formatAlpha                    , transformable: true , convert: convertHexValue   , interpolate: interpolateNumber, type: "alpha" }
		alpha1:   { pattern: "\\1a&H(%x%x)&"     , tag: "\\1a"   , format: formatAlpha , style: "color1"  , transformable: true , convert: convertHexValue   , interpolate: interpolateNumber, type: "alpha" }
		alpha2:   { pattern: "\\2a&H(%x%x)&"     , tag: "\\2a"   , format: formatAlpha , style: "color2"  , transformable: true , convert: convertHexValue   , interpolate: interpolateNumber, type: "alpha" }
		alpha3:   { pattern: "\\3a&H(%x%x)&"     , tag: "\\3a"   , format: formatAlpha , style: "color3"  , transformable: true , convert: convertHexValue   , interpolate: interpolateNumber, type: "alpha" }
		alpha4:   { pattern: "\\4a&H(%x%x)&"     , tag: "\\4a"   , format: formatAlpha , style: "color4"  , transformable: true , convert: convertHexValue   , interpolate: interpolateNumber, type: "alpha" }
		color1:   { pattern: "\\1?c&H(%x+)&"     , tag: "\\1c"   , format: formatColor , style: "color1"  , transformable: true , convert: convertColorValue , interpolate: interpolateColor , type: "color" }
		color2:   { pattern: "\\2c&H(%x+)&"      , tag: "\\2c"   , format: formatColor , style: "color2"  , transformable: true , convert: convertColorValue , interpolate: interpolateColor , type: "color" }
		color3:   { pattern: "\\3c&H(%x+)&"      , tag: "\\3c"   , format: formatColor , style: "color3"  , transformable: true , convert: convertColorValue , interpolate: interpolateColor , type: "color" }
		color4:   { pattern: "\\4c&H(%x+)&"      , tag: "\\4c"   , format: formatColor , style: "color4"  , transformable: true , convert: convertColorValue , interpolate: interpolateColor , type: "color" }
		be:       { pattern: "\\be([%d%.]+)"     , tag: "\\be"   , format: formatInt                      , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		blur:     { pattern: "\\blur([%d%.]+)"   , tag: "\\blur" , format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		xshear:   { pattern: "\\fax([%-%d%.]+)"  , tag: "\\fax"  , format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		yshear:   { pattern: "\\fay([%-%d%.]+)"  , tag: "\\fay"  , format: formatFloat                    , transformable: true , convert: convertNumberValue, interpolate: interpolateNumber }
		align:    { pattern: "\\an([1-9])"       , tag: "\\an"   , format: formatInt   , style: "align"                         , convert: convertNumberValue                                 }
		-- bold, italic, underline and strikeout are actually stored in the style table as boolean values.
		bold:     { pattern: "\\b(%d+)"          , tag: "\\b"    , format: formatInt   , style: "bold"                          , convert: convertNumberValue }
		underline:{ pattern: "\\u([01])"         , tag: "\\u"    , format: formatInt   , style: "underline"                     , convert: convertNumberValue }
		italic:   { pattern: "\\i([01])"         , tag: "\\i"    , format: formatInt   , style: "italic"                        , convert: convertNumberValue }
		strike:   { pattern: "\\s([01])"         , tag: "\\s"    , format: formatInt   , style: "strikeout"                     , convert: convertNumberValue }
		drawing:  { pattern: "\\p(%d+)"          , tag: "\\p"    , format: formatInt                                            , convert: convertNumberValue    }
		transform:{ pattern: "\\t(%b())"         , tag: "\\t"    , format: formatTransform                                      , convert: convertTransformValue }
		-- Problematic tags:
		pos:      { fieldnames: { "x", "y" }        , output: "multi", pattern: "\\pos%(([%.%d%-]+,[%.%d%-]+)%)", tag: "\\pos"  , format: formatMulti, convert: convertMultiValue }
		org:      { fieldnames: { "x", "y" }        , output: "multi", pattern: "\\org%(([%.%d%-]+,[%.%d%-]+)%)", tag: "\\org"  , format: formatMulti, convert: convertMultiValue }
		fad:      { fieldnames: { "in", "out" }     , output: "multi", pattern: "\\fad%((%d+,%d+)%)"            , tag: "\\fad"  , format: formatMulti, convert: convertMultiValue }
		vectClip: { fieldnames: { "scale", "shape" }, output: "multi", pattern: "\\clip%((%d+,)?([^,]-)%)"      , tag: "\\clip" , format: formatMulti, convert: convertMultiValue }
		vectiClip:{ fieldnames: { "scale", "shape" }, output: "multi", pattern: "\\iclip%((%d+,)?([^,]-)%)"     , tag: "\\iclip", format: formatMulti, convert: convertMultiValue }
		rectClip: { fieldnames: { "xLeft", "yTop", "xRight", "yBottom" }, output: "multi", pattern: "\\clip%(([%-%d%.]+,[%-%d%.]+,[%-%d%.]+,[%-%d%.]+)%)" , transformable: true, tag: "\\clip" , format: formatMulti, convert: convertMultiValue, interpolate: interpolateMulti }
		rectiClip:{ fieldnames: { "xLeft", "yTop", "xRight", "yBottom" }, output: "multi", pattern: "\\iclip%(([%-%d%.]+,[%-%d%.]+,[%-%d%.]+,[%-%d%.]+)%)", transformable: true, tag: "\\iclip", format: formatMulti, convert: convertMultiValue, interpolate: interpolateMulti }
		move:     { fieldnames: { "x1", "y1", "x2", "y2", "start", "end" },     output: "multi", pattern: "\\move%(([%.%d%-]+,[%.%d%-]+,[%.%d%-]+,[%.%d%-]+,[%d%-]+,[%d%-]+)%)", tag: "\\move" , format: formatMulti, convert: convertMultiValue }
		fade:     { fieldnames: { "a1", "a2", "a3", "a4", "in", "mid", "out" }, output: "multi", pattern: "\\fade%((%d+,%d+,%d+,%d+,[%d%-]+,[%d%-]+,[%d%-]+)%)"                , tag: "\\fade" , format: formatMulti, convert: convertMultiValue }
	}
}