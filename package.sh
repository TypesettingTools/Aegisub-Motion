#!/usr/bin/env sh

if [ -n "$1" ]; then
	git stash save -a > /dev/null
	git checkout $1
	mkdir -p aegisub-motion-$1/include/a-mo
	mkdir -p aegisub-motion-$1/autoload
	rm -rf src/*.lua
	`which moon` VersionDetemplater.moon
	cp -R src/ aegisub-motion-$1/include/a-mo
	cp -R inc/luajson/lua/ aegisub-motion-$1/include
	cp Aegisub-Motion.moon aegisub-motion-$1/autoload/a-mo.Aegisub-Motion.moon
	cp Install.txt aegisub-motion-$1
	zip -r aegisub-motion-$1.zip aegisub-motion-$1
	rm -rf aegisub-motion-$1
	git reset --hard @
	git checkout master
	git stash pop > /dev/null
else
	echo "You gotta specify a tag."
fi
