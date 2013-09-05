## Aegisub-Motion.moon ##

Aegisub-Motion has been ported to [moonscript][moonscript] by tophf who is a pretty cool guy.  Aegisub-Motion.moon is now the main version, but it will only run on [recent trunk builds][aegplork] of Aegisub. Older versions, such as the 3.0.x branch need to use Aegisub-Motion.lua, which is now built from Aegisub-Motion.moon.

### Motion Trackers ###
If you don't feel like sticking it to the man and stealing extremely expensive software from Imagineer Systems (don't lie to me, I know you weren't paying for [Mocha Pro][mocha]), lachs0r made [an export script][bscript] for [Blender][blender] as well as [a video tutorial][btut] on how to actually track motion in Blender.

### [Documentation][docu] ###

**TODO**
- Re-add plotting capability? Maybe?
- Remove random unnecessary code (there is still a lot, I bet!)
- Make UI separate from the backend code
- Attempt to reproduce a bug where the cleanup was magically deleting lines for no good reason

### Usage ###

Aegisub-Motion requires Aegisub 3.0.X or better, which is now the official stable version of Aegisub. You're strongly urged to update if you haven't already.

No previous versions of Aegisub are supported (the script will simply refuse to load). If bugs in the old version are reported, I will fix them, but the new features will not end up being backported.

The input motion data must be a specific variant of `Adobe After Effects 6.0 Keyframe Data`. For Mocha, export to `After Effects Transform Data [anchor point, position, scale and rotation](*.txt)`). The data format looks like this:

```
Adobe After Effects 6.0 Keyframe Data

	Units Per Second	23.976
	Source Width	1280
	Source Height	720
	Source Pixel Aspect Ratio	1
	Comp Pixel Aspect Ratio	1

Anchor Point
	Frame	X pixels	Y pixels	Z pixels
	301	631.721	60.102	0
	302	631.638	67.4154	0

Position
	Frame	X pixels	Y pixels	Z pixels
	301	631.721	60.102	0
	302	631.638	67.4154	0

Scale
	Frame	X percent	Y percent	Z percent
	301	199.755	199.755	100
	302	198.532	198.532	100

Rotation
	Frame	Degrees
	301	-44.5743
	302	-44.0877

End of Keyframe Data
```

### Features ###

Currently, Aegisub-Motion supports modifying a line's position, scale, and rotation according to user input. It is also capable of modifying those three attributes of an accompanying `\\i?clip()`, to make it change with the line, or separately, if indepentent tracking data is provided. If a line contains transforms, then they will be segmented across the output lines to make the transform effect appear correctly. It should have full support for vfr video sources, because all of its time calculations get frame timestamps directly from Aegisub.

It sports a semi-advanced post-processing cleanup function that removes duplicate tags, cleans up override blocks, and cleans up transform tags that have already completed or have yet to start. It will also join lines that are identical, so if there are no changes made between two lines, they will be merged together.

The output can be sorted by one of two methods: the default, which is to place each tracked line sequentially after its source line, and by time, which sorts the output lines by their start time.

The second macro can trim and encode the current scene to an H.264-in-mp4 file or an image sequence ready for motion tracking. It can utilize x264, ffmpeg, avisynth, or potentially many other command-line tools to do this (ffmpeg is not frame accurate, and avisynth needs ffms2 or another frame accurate source filter to be, well, frame accurate.)

It uses a very simple external configuration file to save user input across scripts. The config writing functions should no longer be capable of erasing the contents of config file if they error.

### Troubleshooting ###

If the script fails to load, it might be a problem on your end. Check it to make sure your browser hasn't inserted HTML tags into it. Otherwise, simply [notify me](#contact) and I will fix it as soon as possible.

If the script crashes in mid-use and you can't get it to work, please provide me with a copy of your config, the lines to which you are applying the data, and a copy of the motion data. If I can reproduce the problem, I should be able to fix it. Just saying "I'M HAVING AN ERROR" is not very helpful.

### Acknowledgements ###

Many bugs have been reported by various users, and if you've reported something that I've managed to fix, thank you. I'd like to thank tophf and tp7 in particular for both finding many bugs as well as suggesting several useful features. I'd also like to thank Plorkyeran for listening to several of my crazy suggestions about expanding aegisub's Automation capabilities.

### Contact ###

I'm typically available as `torque` on `irc.rizon.net`. Feel free to PM me with suggestions, requests or questions. I am not always at the computer, but if you leave me a message, I will get back to you when I can.

[moonscript]: http://moonscript.org/
[bscript]: https://gist.github.com/torque/6453947/raw/f2faa10114edf46307c47307ae3b7f6d215c5bc6/gistfile1.py
[blender]: http://www.blender.org/
[btut]: https://www.youtube.com/watch?v=lHgiRjKr4Iw
[docu]: https://github.com/torque/Aegisub-Motion/wiki
[aegplork]: http://plorkyeran.com/aegisub/
[mocha]: http://www.imagineersystems.com/
