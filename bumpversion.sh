#!/bin/sh

pushd "`git rev-parse --show-toplevel`"
# Stash everything to remove untracked files from repository without
# deleting them.
git stash save -a
git branch -D DepCtrl
git checkout --orphan DepCtrl
# All files are staged for commit by default, which we don't want.
git rm --cached -f '*'
`which moon` VersionDetemplater.moon
git add Aegisub-Motion.moon DependencyControl.json src/*.moon
git commit -m "Update."
# remove untracked files so we can switch back to master.
git clean -fdx
git checkout master
git stash pop
