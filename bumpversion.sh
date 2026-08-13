#!/bin/sh

if ! command -v moon >/dev/null 2>&1; then
	echo "MoonScript is required to generate release files." >&2
	exit 1
fi

cd "$(git rev-parse --show-toplevel)" || exit 1
# Stash everything to remove untracked files from repository without
# deleting them.
git stash save -a
git branch -D DepCtrl
git checkout --orphan DepCtrl
# All files are staged for commit by default, which we don't want.
git rm --cached -f '*'
if ! moon VersionDetemplater.moon; then
	echo "Failed to generate versioned release files." >&2
	exit 1
fi
mv 'Aegisub-Motion.moon' 'a-mo.Aegisub-Motion.moon'
git add 'a-mo.Aegisub-Motion.moon' 'DependencyControl.json' src/*.moon
git commit -m 'Update.'
# remove untracked files so we can switch back to master.
git clean -fdx
git checkout master
git stash pop
