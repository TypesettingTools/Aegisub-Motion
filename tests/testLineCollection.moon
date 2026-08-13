-- Load the working-tree modules directly instead of allowing DependencyControl
-- to substitute published versions.
json = require 'l0.dkjson'
package.loaded['json'] = json
package.loaded['l0.DependencyControl'] = nil
package.preload['l0.DependencyControl'] = ->
	error 'DependencyControl is intentionally disabled by the test suite.'

Line = require 'a-mo.Line'
LineCollection = require 'a-mo.LineCollection'
MotionHandler = require 'a-mo.MotionHandler'
Tags = require 'a-mo.Tags'
log = require 'a-mo.Log'

project_name = "Aegisub-Motion"
export script_name = "Tests/LineCollection"
export script_description = "Tests LineCollection and Line classes."

ourLines = {
	defaults: {
		actor: "", class: "dialogue", comment: false, effect: "banner",
		start_time: 0, end_time: 1000, extra: {}, layer: 0,
		margin_l: 0, margin_r: 0, margin_t: 0, section: "[Events]"
		style: "Default"
		text: "Hi, I am a line."
	}

	theLines: {
		{ }
		{ start_time: 1000, end_time:2000
		  text: "{\\fad(150,300)}I am fading out of existence.{\\fad(150,305)}" }
		{ start_time: 2000, end_time:3000
		  text: "{\\t(\\1c&HFF0000&)}I {\\t(0,0,\\1c&H00FF00&)}am {\\t(2.345,\\1c&H0000FF&)}transforming." }
		{ actor: "issue69", start_time: 3000, end_time:4000
		  text: "{\\c&H1C3724&\\3c&H0C2C0C&\\t(2984,3860,\\c&H09140C&\\3c&H041605&)}Text" }
		{ start_time: 4000, end_time:5000
		  text: "We are Identical." }
		{ start_time: 3500, end_time:4000
		  text: "We are Identical." }
		{ start_time: 3000, end_time:3500
		  text: "We are Identical." }
		{ start_time: 5000, end_time:6000
		  text: '{\\pos(0,0)\\an7\\c&H000000&\\c&H0000FF&\\clip(80,185,425,247.5)}#{fullFrame}' }
		{ start_time: 6000, end_time:7000
		  text: '{\\pos(0,0)\\an7\\c&H000000&\\clip(3,m 80 185 l 320 212 425 247 45 244)}#{fullFrame}' }
	}

	iterator: =>
		i = 1
		n = #@theLines
		return ->
			if i <= n
				theLine = @theLines[i]
				i += 1
				for k,v in pairs @defaults
					theLine[k] = theLine[k] or v

				theLine.text = theLine.text\gsub "#%{fullFrame%}", ->
					@fullFrame!

				return theLine

	fullFrame: ->
		width, height = aegisub.video_size!
		("{\\p1}m 0 0 l %d 0 %d %d 0 %d{\\p0}")\format width, width, height, height
}

-- Audit regression tests

fixtureMarker = "a-mo-regression-fixture"

assertEqual = ( expected, actual, message ) ->
	unless expected == actual
		error "#{message}\nExpected: #{tostring expected}\nActual: #{tostring actual}"

makeDialogue = ( style, overrides = { } ) ->
	line = {
		actor: fixtureMarker
		class: "dialogue"
		comment: false
		effect: ""
		start_time: 0
		end_time: 1000
		extra: { }
		layer: 0
		margin_l: 0
		margin_r: 0
		margin_t: 0
		section: "[Events]"
		:style
		text: "Regression fixture"
	}

	for key, value in pairs overrides
		line[key] = value
	line

cleanupFixtures = ( subtitles ) ->
	indices = { }
	for i = #subtitles, 1, -1
		line = subtitles[i]
		if line.class == "dialogue" and line.actor == fixtureMarker
			indices[#indices+1] = i
	subtitles.delete indices if #indices > 0

withFixtures = ( subtitles, lines, callback ) ->
	first = #subtitles + 1
	subtitles.insert first, unpack lines

	ok, result = xpcall (-> callback first), ( err ) -> debug.traceback tostring( err ), 2
	cleanupFixtures subtitles
	error result unless ok
	result

testClipOnlyTrackingWithoutMainData = ( subtitles, style ) ->
	startTime = aegisub.ms_from_frame 0
	endTime = aegisub.ms_from_frame 2
	line = makeDialogue style, {
		start_time: startTime
		end_time: endTime
		text: "{\\pos(0,0)\\clip(0,0,10,10)}Clip only"
	}

	withFixtures subtitles, { line }, ( first ) ->
		collection = LineCollection subtitles, { first }
		collection.options = {
			main: {
				absPos: false
				blur: false
				blurScale: 1
				border: false
				clipOnly: false
				killTrans: false
				linear: false
				origin: false
				shadow: false
				xPosition: false
				xScale: false
				yPosition: false
				zRotation: false
			}
		}

		collection.lines[1]\tokenizeTransforms!
		trackingData = {
			xCurrentPosition: 5
			xRatio: 1
			xStartPosition: 0
			yCurrentPosition: 7
			yRatio: 1
			yStartPosition: 0
			zRotationDiff: 0
			calculateCurrentState: ( frame ) =>
				@xCurrentPosition = 5
				@yCurrentPosition = 7
				@xRatio = 1
				@yRatio = 1
				@zRotationDiff = 0
		}

		handler = MotionHandler collection, { }, { type: "TSR", dataObject: trackingData }
		result = handler\applyMotion!
		assert #result.lines > 0, "Clip-only tracking produced no output lines."
		assert result.lines[1].text\find("\\clip(5,7,15,17)", 1, true), "Clip-only tracking did not apply the clip data."

testTransformIgnoresTagsAfterTransform = ( style ) ->
	parentCollection = { meta: { PlayResX: 1280, PlayResY: 720 } }
	line = Line makeDialogue(style, {
		text: "{\\bord1\\t(0,1000,\\bord3)\\bord9}Transform"
	}), parentCollection
	border = Tags.allTags.border
	line.properties = { [border]: 0 }
	line\tokenizeTransforms!

	transform = line.transforms[1]
	assert transform, "The transform fixture was not tokenized."
	transform\collectPriorState line, line.text, transform.token
	assertEqual 1, transform.priorValues[border], "A tag after the transform overwrote the transform's prior state."

testConflictingOneTimeTags = ( style ) ->
	firstWins = {
		{
			"{\\pos(1,2)\\bord1\\move(1,2,3,4,0,100)}Position"
			"{\\pos(1,2)\\bord1}Position"
		}
		{
			"{\\move(1,2,3,4,0,100)\\bord1\\pos(1,2)}Position"
			"{\\move(1,2,3,4,0,100)\\bord1}Position"
		}
		{
			"{\\pos(1,2)\\bord1\\move(1,2,3,4)}Position"
			"{\\pos(1,2)\\bord1}Position"
		}
		{
			"{\\move(1,2,3,4)\\bord1\\pos(1,2)}Position"
			"{\\move(1,2,3,4)\\bord1}Position"
		}
		{
			"{\\fad(100,200)\\bord1\\fade(0,255,0,0,100,200,300)}Fade"
			"{\\fad(100,200)\\bord1}Fade"
		}
		{
			"{\\fade(0,255,0,0,100,200,300)\\bord1\\fad(100,200)}Fade"
			"{\\fade(0,255,0,0,100,200,300)\\bord1}Fade"
		}
		{
			"{\\clip(m 0 0 l 10 0 10 10 0 10)\\bord1\\iclip(m 2 2 l 8 2 8 8 2 8)}Vector"
			"{\\clip(m 0 0 l 10 0 10 10 0 10)\\bord1}Vector"
		}
		{
			"{\\iclip(m 2 2 l 8 2 8 8 2 8)\\bord1\\clip(m 0 0 l 10 0 10 10 0 10)}Vector"
			"{\\iclip(m 2 2 l 8 2 8 8 2 8)\\bord1}Vector"
		}
		{
			"{\\clip(2,m 0 0 l 10 0 10 10 0 10)\\bord1\\iclip(3,m 2 2 l 8 2 8 8 2 8)}Vector"
			"{\\clip(2,m 0 0 l 10 0 10 10 0 10)\\bord1}Vector"
		}
	}

	for fixture in *firstWins
		line = Line makeDialogue style, { text: fixture[1] }
		line\deduplicateTags!
		assertEqual fixture[2], line.text, "A first-wins tag conflict was resolved incorrectly."

	originalOneTimeTags = Tags.oneTimeTags
	Tags.oneTimeTags = { Tags.allTags.move, Tags.allTags.org, Tags.allTags.pos }
	orderSensitiveLine = Line makeDialogue style, {
		text: "{\\org(1,1)\\org(1,1)\\org(1,1)\\org(1,1)\\move(0,0,5,5,0,100)\\pos(0,0)}Position"
	}
	orderSensitiveLine\deduplicateTags!
	Tags.oneTimeTags = originalOneTimeTags
	assertEqual "{\\org(1,1)\\move(0,0,5,5,0,100)}Position", orderSensitiveLine.text,
		"Removing earlier duplicate tags changed the first-wins source order."

	sequentialRectClips = {
		"{\\clip(0,0,10,10)\\clip(1,1,9,9)}Rectangle"
		"{\\clip(0,0,10,10)\\iclip(1,1,9,9)}Rectangle"
		"{\\iclip(1,1,9,9)\\clip(0,0,10,10)}Rectangle"
		"{\\clip(0,0,10,10)\\t(0,1000,\\iclip(1,1,9,9))}Rectangle"
		"{\\clip(0,0,10,10)\\iclip(m 2 2 l 8 2 8 8 2 8)}Mixed clips"
	}

	for text in *sequentialRectClips
		line = Line makeDialogue style, { :text }
		line\deduplicateTags!
		assertEqual text, line.text, "Sequential rectangular clips were discarded or reordered."

testCommentSelections = ( subtitles, style ) ->
	start0 = aegisub.ms_from_frame 0
	start1 = aegisub.ms_from_frame 1
	start2 = aegisub.ms_from_frame 2
	lines = {
		makeDialogue style, {
			comment: true
			start_time: start0
			end_time: start1
			text: "Comment"
		}
		makeDialogue style, {
			start_time: start1
			end_time: start2
			text: "Dialogue"
		}
	}

	withFixtures subtitles, lines, ( first ) ->
		commentOnly = LineCollection subtitles, { first }
		assert (#commentOnly.lines == 0 and commentOnly.startTime == nil and commentOnly.endTime == nil and
			commentOnly.startFrame == nil and commentOnly.endFrame == nil), "A comment-only selection retained a timing range."

		mixed = LineCollection subtitles, { first, first + 1 }
		assert mixed.startTime == start1 and mixed.endTime == start2, "A leading comment changed the selected dialogue range."

testLineMergingPreservesProperties = ( style ) ->
	control = Line makeDialogue style, { start_time: 0, end_time: 100, text: "Control" }
	continuation = Line makeDialogue style, { start_time: 100, end_time: 200, text: "Control" }
	assert control\combineWithLine(continuation), "Otherwise identical adjacent lines were not merged."
	assertEqual 200, control.end_time, "The positive-control merge did not extend the line timing."

	variants = {
		{ "layer", 1 }
		{ "margin_l", 10 }
		{ "margin_r", 10 }
		{ "margin_t", 10 }
		{ "effect", "different" }
		{ "extra", { ['a-mo']: "different uuid" } }
	}
	merged = { }

	for variant in *variants
		field, value = variant[1], variant[2]
		left = Line makeDialogue style, {
			start_time: 0
			end_time: 100
			text: "Identical"
			extra: { ['a-mo']: "first uuid" }
		}
		right = Line makeDialogue style, {
			start_time: 100
			end_time: 200
			text: "Identical"
			extra: { ['a-mo']: "first uuid" }
			[field]: value
		}
		merged[#merged+1] = field if left\combineWithLine right

	assert #merged == 0, "Lines with different properties were merged: #{table.concat merged, ', '}"

testSetAllTagValues = ( style ) ->
	line = Line makeDialogue style, { text: "{\\bord1}One{\\bord2}Two" }
	line\setAllTagValues Tags.allTags.border, { 3, 4 }
	assertEqual "{\\bord3}One{\\bord4}Two", line.text, "setAllTagValues did not replace each tag value."

runAuditRegressions = ( subtitles, style ) ->
	for test in *{
		{ "clip-only tracking", -> testClipOnlyTrackingWithoutMainData subtitles, style }
		{ "transform prior state", -> testTransformIgnoresTagsAfterTransform style }
		{ "one-time tag conflicts", -> testConflictingOneTimeTags style }
		{ "comment selections", -> testCommentSelections subtitles, style }
		{ "line property merging", -> testLineMergingPreservesProperties style }
		{ "setAllTagValues", -> testSetAllTagValues style }
	}
		aegisub.progress.task "Regression: #{test[1]}"
		test[2]!
		log.warn "PASS: #{test[1]}"


testLineCollection = ( subtitles, selectedLines, activeLine ) ->
	runAuditRegressions subtitles, ourLines.defaults.style

	-- We're just going to insert our subtitles here because it's
	-- guaranteed to be valid.
	first = selectedLines[1]

	-- Generate our the lines to insert using the template.
	theLines = [ line for line in ourLines\iterator! ]

	-- Actually insert the lines.
	subtitles.insert first, unpack theLines

	-- "Select" the lines we just inserted by generating a table of their
	-- indices.
	newSelLines = [ i for i = first, #theLines + first - 1 ]

	-- Instantiate our LineCollection class.
	ourLineCollection = LineCollection subtitles, newSelLines

	ourLineCollection\callMethodOnAllLines "deduplicateTags"
	for line in *ourLineCollection.lines
		if line.actor == "issue69"
			assert line.text == "{\\c&H1C3724&\\3c&H0C2C0C&\\t(2984,3860,\\c&H09140C&\\3c&H041605&)}Text"

	-- Do an in-place replace of the lines we have just abused.
	ourLineCollection\replaceLines!

canRun = ( sub, sel ) ->
	if not aegisub.frame_from_ms 0
		return false, "You must have a video loaded to run this macro."
	elseif 0 == #sel
		return false, "You must have lines selected to use this macro."
	true

aegisub.register_macro "#{project_name}/#{script_name}", script_description, testLineCollection, canRun
