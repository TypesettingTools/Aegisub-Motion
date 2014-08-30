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

interpolateColor = ( before, after, progress ) =>
	return interpolateMulti { fieldnames: { 'b', 'g', 'r' } }, before, after, progress

interpolateMulti = ( before, after, progress ) =>
	result = { }
	for index = 1, #@fieldnames
		key = @fieldnames[index]
		result[index] = interpolateNumber before[index], after[index], progress
		result[key]   = result[index]

	return result

return {
	repeatTags: {
		"fontName", "fontSize", "fontSp", "xscale", "yscale", "zrot", "xrot", "yrot", "border", "xborder", "yborder", "shadow", "xshadow", "yshadow", "reset", "alpha", "alpha1", "alpha2", "alpha3", "alpha4", "color1", "color2", "color3", "color4", "be", "blur", "xshear", "yshear", "drawing"
	}

	oneTimeTags: {
		"align", "pos", "move", "org", "fad", "fade", "rectClip", "rectiClip", "vectClip", "vectiClip"
	}

	allTags: {
		fontName: { pattern: "\\fn([^\\}]+)"     , output: "string", type: "font"    , format: "\\fn%s"             , style: "fontname"                      , convertValue: convertStringValue                                 }
		fontSize: { pattern: "\\fs(%d+)"         , output: "number", type: "scale"   , format: "\\fs%d"             , style: "fontsize", transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		fontSp:   { pattern: "\\fsp([%.%d%-]+)"  , output: "number", type: "scale"   , format: "\\fsp%g"            , style: "spacing" , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		xscale:   { pattern: "\\fscx([%d%.]+)"   , output: "number", type: "scale"   , format: "\\fscx%g"           , style: "scale_x" , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		yscale:   { pattern: "\\fscy([%d%.]+)"   , output: "number", type: "scale"   , format: "\\fscx%g"           , style: "scale_y" , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		zrot:     { pattern: "\\frz?([%-%d%.]+)" , output: "number", type: "rotation", format: "\\frz%g"            , style: "angle"   , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		xrot:     { pattern: "\\frx([%-%d%.]+)"  , output: "number", type: "rotation", format: "\\frx%g"                               , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		yrot:     { pattern: "\\fry([%-%d%.]+)"  , output: "number", type: "rotation", format: "\\fry%g"                               , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		border:   { pattern: "\\bord([%d%.]+)"   , output: "number", type: "border"  , format: "\\bord%g"                              , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		xborder:  { pattern: "\\xbord([%d%.]+)"  , output: "number", type: "border"  , format: "\\xbord%g"          , style: "outline" , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		yborder:  { pattern: "\\ybord([%d%.]+)"  , output: "number", type: "border"  , format: "\\ybord%g"          , style: "outline" , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		shadow:   { pattern: "\\shad([%-%d%.]+)" , output: "number", type: "shadow"  , format: "\\shad%g"                              , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		xshadow:  { pattern: "\\xshad([%-%d%.]+)", output: "number", type: "shadow"  , format: "\\xshad%g"          , style: "shadow"  , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		yshadow:  { pattern: "\\yshad([%-%d%.]+)", output: "number", type: "shadow"  , format: "\\yshad%g"          , style: "shadow"  , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		reset:    { pattern: "\\r([^\\}]*)"      , output: "string", type: "style"   , format: "\\r%s"                                                       , convertValue: convertStringValue                                 }
		alpha:    { pattern: "\\alpha&H(%x%x)&"  , output: "alpha" , type: "alpha"   , format: "\\alpha&H%02X&"                        , transformable: true , convertValue: convertHexValue   , interpolate: interpolateNumber }
		alpha1:   { pattern: "\\1a&H(%x%x)&"     , output: "alpha" , type: "alpha"   , format: "\\1a&H%02X&"        , style: "color1"  , transformable: true , convertValue: convertHexValue   , interpolate: interpolateNumber }
		alpha2:   { pattern: "\\2a&H(%x%x)&"     , output: "alpha" , type: "alpha"   , format: "\\2a&H%02X&"        , style: "color2"  , transformable: true , convertValue: convertHexValue   , interpolate: interpolateNumber }
		alpha3:   { pattern: "\\3a&H(%x%x)&"     , output: "alpha" , type: "alpha"   , format: "\\3a&H%02X&"        , style: "color3"  , transformable: true , convertValue: convertHexValue   , interpolate: interpolateNumber }
		alpha4:   { pattern: "\\4a&H(%x%x)&"     , output: "alpha" , type: "alpha"   , format: "\\4a&H%02X&"        , style: "color4"  , transformable: true , convertValue: convertHexValue   , interpolate: interpolateNumber }
		color1:   { pattern: "\\1?c&H(%x+)&"     , output: "color" , type: "color"   , format: "\\1c&H%02X%02X%02X&", style: "color1"  , transformable: true , convertValue: convertHexValue   , interpolate: interpolateColor  }
		color2:   { pattern: "\\2c&H(%x+)&"      , output: "color" , type: "color"   , format: "\\2c&H%02X%02X%02X&", style: "color2"  , transformable: true , convertValue: convertHexValue   , interpolate: interpolateColor  }
		color3:   { pattern: "\\3c&H(%x+)&"      , output: "color" , type: "color"   , format: "\\3c&H%02X%02X%02X&", style: "color3"  , transformable: true , convertValue: convertHexValue   , interpolate: interpolateColor  }
		color4:   { pattern: "\\4c&H(%x+)&"      , output: "color" , type: "color"   , format: "\\4c&H%02X%02X%02X&", style: "color4"  , transformable: true , convertValue: convertHexValue   , interpolate: interpolateColor  }
		be:       { pattern: "\\be([%d%.]+)"     , output: "number", type: "blur"    , format: "\\be%d"                                , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		blur:     { pattern: "\\blur([%d%.]+)"   , output: "number", type: "blur"    , format: "\\blur%g"                              , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		xshear:   { pattern: "\\fax([%-%d%.]+)"  , output: "number", type: "shear"   , format: "\\fax%g"                               , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		yshear:   { pattern: "\\fay([%-%d%.]+)"  , output: "number", type: "shear"   , format: "\\fay%g"                               , transformable: true , convertValue: convertNumberValue, interpolate: interpolateNumber }
		align:    { pattern: "\\an([1-9])"       , output: "number", type: "align"   , format: "\\an%d"             , style: "align"                         , convertValue: convertNumberValue                                 }
		bold:     { pattern: "\\b(%d+)"          , output: "number", type: "accent"  , format: "\\b%d"              , style: "bold"                          , convertValue: convertNumberValue }
		italic:   { pattern: "\\i([01])"         , output: "number", type: "accent"  , format: "\\i%d"              , style: "italic"                        , convertValue: convertNumberValue }
		strike:   { pattern: "\\s([01])"         , output: "number", type: "accent"  , format: "\\s%d"              , style: "bold"                          , convertValue: convertNumberValue }
		drawing:  { pattern: "\\p(%d+)"          , output: "number"   , convertValue: convertNumberValue    }
		transform:{ pattern: "\\t(%b())"         , output: "transform", convertValue: convertTransformValue }
		-- Problematic tags:
		pos:      { fieldnames: { "x", "y" },      output: "multi", pattern: "\\pos%(([%.%d%-]+,[%.%d%-]+)%)", convertValue: convertMultiValue }
		org:      { fieldnames: { "x", "y" },      output: "multi", pattern: "\\org%(([%.%d%-]+,[%.%d%-]+)%)", convertValue: convertMultiValue }
		fad:      { fieldnames: { "in", "out" },   output: "multi", pattern: "\\fad%((%d+,%d+)%)"            , convertValue: convertMultiValue }
		vectClip: { fieldnames: { "scale", "shape" }, output: "multi", pattern: "\\clip%((%d+,)?([^,]-)%)"   , convertValue: convertMultiValue }
		vectiClip:{ fieldnames: { "scale", "shape" }, output: "multi", pattern: "\\iclip%((%d+,)?([^,]-)%)"  , convertValue: convertMultiValue }
		rectClip: { fieldnames: { "xLeft", "yTop", "xRight", "yBottom" }, output: "multi", pattern: "\\clip%(([%-%d%.]+,[%-%d%.]+,[%-%d%.]+,[%-%d%.]+)%)" , transformable: true, convertValue: convertMultiValue, interpolate: interpolateMulti }
		rectiClip:{ fieldnames: { "xLeft", "yTop", "xRight", "yBottom" }, output: "multi", pattern: "\\iclip%(([%-%d%.]+,[%-%d%.]+,[%-%d%.]+,[%-%d%.]+)%)", transformable: true, convertValue: convertMultiValue, interpolate: interpolateMulti }
		move:     { fieldnames: { "x1", "y1", "x2", "y2", "start", "end" },     output: "multi", pattern: "\\move%(([%.%d%-]+,[%.%d%-]+,[%.%d%-]+,[%.%d%-]+,[%d%-]+,[%d%-]+)%)", convertValue: convertMultiValue }
		fade:     { fieldnames: { "a1", "a2", "a3", "a4", "in", "mid", "out" }, output: "multi", pattern: "\\fade%((%d+,%d+,%d+,%d+,[%d%-]+,[%d%-]+,[%d%-]+)%)", convertValue: convertMultiValue }
	}
}
