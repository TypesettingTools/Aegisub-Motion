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

tests = {
	{ "#1 TrimHandler loads", (_, _) -> testTrimHandlerLoads! }
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
