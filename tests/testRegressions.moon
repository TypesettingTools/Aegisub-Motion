-- Exercise the modules copied from this working tree, rather than allowing
-- DependencyControl to substitute modules from the published feed. The
-- DependencyControl installation supplies dkjson, which we expose under the
-- legacy module name used by Aegisub-Motion's fallback loader.
json = require 'l0.dkjson'
package.loaded['json'] = json
package.loaded['l0.DependencyControl'] = nil
package.preload['l0.DependencyControl'] = ->
	error 'DependencyControl is intentionally disabled by the regression suite.'

Line = require 'a-mo.Line'
LineCollection = require 'a-mo.LineCollection'
MotionHandler = require 'a-mo.MotionHandler'
Tags = require 'a-mo.Tags'

project_name = "Aegisub-Motion"
export script_name = "Tests/Regressions"
export script_description = "Runs regression tests for previously identified Aegisub-Motion bugs."

fixtureMarker = "a-mo-regression-fixture"

traceback = ( err ) ->
	debug.traceback tostring( err ), 2

assertEqual = ( expected, actual, message ) ->
	unless expected == actual
		error "#{message}\nExpected: #{tostring expected}\nActual: #{tostring actual}"

findStyle = ( subtitles ) ->
	for i = 1, #subtitles
		line = subtitles[i]
		if line.class == "style"
			return line.name
	error "The regression suite requires at least one style."

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

	ok, result = xpcall (-> callback first), traceback
	cleanupFixtures subtitles
	error result unless ok
	result

testTrimHandlerLoads = ->
	ok, result = pcall require, 'a-mo.TrimHandler'
	assert ok, "TrimHandler failed to load through Aegisub's MoonScript module loader:\n#{tostring result}"

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
	line = Line makeDialogue style, {
		text: "{\\pos(1,2)\\bord1\\move(1,2,3,4,0,100)}Position"
	}
	line\deduplicateTags!

	assert line.text\find("\\pos", 1, true), "The first conflicting one-time tag was removed."
	assert not line.text\find("\\move", 1, true), "The later conflicting one-time tag was not removed."

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
		problems = { }

		commentOnly = LineCollection subtitles, { first }
		if (#commentOnly.lines != 0 or commentOnly.startTime != nil or commentOnly.endTime != nil or
			commentOnly.startFrame != nil or commentOnly.endFrame != nil)
			problems[#problems+1] = "a comment-only selection retained a timing range"

		mixed = LineCollection subtitles, { first, first + 1 }
		if mixed.startTime != start1 or mixed.endTime != start2
			problems[#problems+1] = "a leading comment changed the selected dialogue range"

		assert #problems == 0, table.concat problems, "; "

tests = {
	{ "#1 TrimHandler loads", (_, _) -> testTrimHandlerLoads! }
	{ "#4 Clip-only tracking works without main data", testClipOnlyTrackingWithoutMainData }
	{ "#5 Transform prior state stops at the transform", (_, style) -> testTransformIgnoresTagsAfterTransform style }
	{ "#6 Conflicting one-time tags are removed", (_, style) -> testConflictingOneTimeTags style }
	{ "#7 Comment selections do not create invalid ranges", testCommentSelections }
}

runRegressionTests = ( subtitles, selectedLines, activeLine ) ->
	style = findStyle subtitles
	results = { }
	failures = 0

	for test in *tests
		name, callback = test[1], test[2]
		aegisub.progress.task name
		ok, err = xpcall (-> callback subtitles, style), traceback
		if ok
			results[#results+1] = "PASS  #{name}"
		else
			failures += 1
			results[#results+1] = "FAIL  #{name}\n      #{tostring(err)\gsub '\n', '\n      '}"

	cleanupFixtures subtitles
	summary = table.concat results, "\n\n"
	aegisub.log 2, "%s\n", summary

	label = if failures == 0
		"All #{#tests} regression tests passed."
	else
		"#{failures} of #{#tests} regression tests failed."

	aegisub.dialog.display {
		{ class: "label", label: label, x: 0, y: 0, width: 1, height: 1 }
		{ class: "textbox", value: summary, x: 0, y: 1, width: 1, height: 18 }
	}, { "Close" }

	if failures > 0
		error "#{failures} regression tests failed. See the test summary above."

	selectedLines, activeLine

canRun = ->
	unless aegisub.frame_from_ms 0
		return false, "Open tests/video/video.ass so the dummy video is loaded before running the regression suite."
	true

aegisub.register_macro "#{project_name}/#{script_name}", script_description, runRegressionTests, canRun
