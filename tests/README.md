# Aegisub-Motion tests

These tests are Automation macros and run inside Aegisub.

The regression suite expects DependencyControl to be installed normally in the
Aegisub user Automation directory. It uses DependencyControl's bundled dkjson,
but bypasses DependencyControl's module resolver while running so that it tests
the modules copied from this working tree instead of published versions.

To install the working-tree regression suite on macOS without symlinks:

```sh
cd /path/to/Aegisub-Motion
AEGI_AUTOMATION="$HOME/Library/Application Support/Aegisub/automation"
mkdir -p "$AEGI_AUTOMATION/include/a-mo" "$AEGI_AUTOMATION/autoload"
cp -R src/. "$AEGI_AUTOMATION/include/a-mo/"
cp tests/testRegressions.moon \
  "$AEGI_AUTOMATION/autoload/a-mo-test-regressions.moon"
```

Then:

1. Restart Aegisub or rescan the autoload directory in Automation Manager.
2. Open `tests/video/video.ass`; its project data loads a dummy video.
3. Run **Automation → Aegisub-Motion → Tests → Regressions**.

The suite creates temporary subtitle lines and removes them before it exits. A
failure summary is shown in a dialog and written to Aegisub's Automation log.
The Revert extradata fix is not included because its implementation remains
local to the main Automation script; the suite otherwise covers each audit fix.
