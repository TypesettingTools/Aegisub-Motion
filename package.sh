#!/usr/bin/env sh

git stash
git checkout $1
mkdir -p release/include/a-mo
mkdir -p release/autoload
cp -R src/ release/include/a-mo
cp -R inc/luajson/lua/ release/include
cp Install.txt release
zip aegisub-motion-$1 release
git checkout master
git stash pop
