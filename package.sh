#!/usr/bin/env sh

if ! command -v moon >/dev/null 2>&1; then
	echo "MoonScript is required to generate release files." >&2
	exit 1
fi

if [ -n "$1" ]; then
	git stash save -a > /dev/null
	git checkout $1
	mkdir -p aegisub-motion-$1/include/a-mo
	mkdir -p aegisub-motion-$1/autoload
	rm -rf src/*.lua
	if ! moon VersionDetemplater.moon; then
		echo "Failed to generate versioned release files." >&2
		exit 1
	fi
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
