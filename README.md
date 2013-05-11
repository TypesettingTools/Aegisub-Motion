## Aegisub-Motion.moon ##

### Aegisub-Motion has been ported to [moonscript][moonscript] by tophf who is a pretty cool guy.  Here's what you need to know: ###
- Recent development versions of Aegisub (see commit [19854e207a][moonscriptcommit]) have native support for moonscript, so if you've been building Aegisub for yourself, you can simply stick Aegisub-Motion.moon in your automation folder and hopefully go gangbusters. Otherwise, you'll need to compile the script to lua yourself, or wait for me to do it.
- The moonscript version is slightly better maybe? There are a few things I should probably backport to lua, but see since I will be replacing the original lua with compiled moon soon, I'm not going to bother.
- For the future, any development that does happen will happen in the moonscript file, which will then be compiled to lua for people with old versions of Aegisub.
- ### I have only quickly glanced over the moonscript file and briefly confirmed that it compiles, so it may contain ERRORS and BUGS. Please do not hesitate to report these to me if you encounter them.

**Important information**
- Every time you update, you should delete and regenerate your configuration file(s).
- This script no longer supports Aegisub 2.1.x. [Click here for the last version that does.][oldver]

### [Documentation][docu] ###

**TODO**
- Make _all_ of the gnuplot related code a lot less terrible
- Remove random unnecessary code (there is still a lot, I bet!)
- Make UI separate from the backend code
- Figure out what the fuck is going on when both org and pos are enabled
- Make automated encoding actually work on non-windows operating systems
- Attempt to reproduce a bug where the cleanup was magically deleting lines for no good reason

### Usage ###

Aegisub-Motion requires Aegisub 3.0.X or better, which is now the official stable version of Aegisub. You're strongly urged to update if you haven't already.

No previous versions of Aegisub are supported (the script will simply refuse to load). If bugs in the old version are reported, I will fix them, but the new features will not end up being backported.

To use this script, you must first have tracked the motion in an external program. The recommended one is [Mocha Pro][mocha], but any motion tracking software should work as long as the data is exported to the right format.

The input motion data must be a specific variant of `Adobe After Effects 6.0 Keyframe Data`. For Mocha, export to `After Effects Transform Data [anchor point, position, scale and rotation](*.txt)`). The data format looks like this:

    Adobe After Effects 6.0 Keyframe Data

      Units Per Second  23.976
      Source Width  1920
      Source Height 1080
      Source Pixel Aspect Ratio 1
      Comp Pixel Aspect Ratio 1

    Anchor Point
      Frame X pixels  Y pixels  Z pixels
      0 1583  180 0

    Position
      Frame X pixels  Y pixels  Z pixels
      0 1583  180 0

    Scale
      Frame X percent Y percent Z percent
      0 100 100 100

    Rotation
      Frame Degrees
      0 0

    End of Keyframe Data

### Features ###

Currently, Aegisub-Motion supports modifying a line's position, scale, and rotation according to user input. It is also capable of modifying those three attributes of an accompanying `\\i?clip()`, to make it change with the line, or separately, if indepentent tracking data is provided. If a line contains transforms, then they will be segmented across the output lines to make the transform effect appear correctly. It should have full support for vfr video sources, because all of its time calculations get frame timestamps directly from Aegisub.

It sports a semi-advanced post-processing cleanup function that removes duplicate tags, cleans up override blocks, and cleans up transform tags that have already completed or have yet to start. It will also join lines that are identical, so if there are no changes made between two lines, they will be merged together.

The output can be sorted by one of two methods: the default, which is to place each tracked line sequentially after its source line, and by time, which sorts the output lines by their start time.

The second macro can trim and encode the current scene to an H.264-in-mp4 file or an image sequence ready for motion tracking. It can utilize x264, ffmpeg, avisynth, or potentially many other command-line tools to do this (ffmpeg is not frame accurate, and avisynth needs ffms2 or another frame accurate source filter to be, well, frame accurate.)

It uses a very simple external configuration file to save user input across scripts. The config writing functions should no longer be capable of erasing the contents of config file if they error.

Finally, it also supports exporting the tracking data into a format that is compatable with [gnuplot][gnuplot], along with gnuplot plotting instructions. It can even plot the data automatically, if you have gnuplot in your PATH.

### Troubleshooting ###

If the script fails to load, it might be a problem on your end. Check it to make sure your browser hasn't inserted HTML tags into it. Otherwise, simply [notify me](#contact) and I will fix it as soon as possible.

If the script crashes in mid-use and you can't get it to work, please provide me with a copy of your config, the lines to which you are applying the data, and a copy of the motion data. If I can reproduce the problem, I should be able to fix it. Just saying "I'M HAVING AN ERROR" is not very helpful.

### Acknowledgements ###

Many bugs have been reported by various users, and if you've reported something that I've managed to fix, thank you. I'd like to thank tophf and tp7 in particular for both finding many bugs as well as suggesting several useful features. I'd also like to thank Plorkyeran for listening to several of my crazy suggestions about expanding aegisub's Automation capabilities.

### Contact ###

I'm typically available as `torque` on `irc.rizon.net`. Feel free to PM me with suggestions, requests or questions.

[moonscript]: http://moonscript.org/
[moonscriptcommit]: https://github.com/Aegisub/Aegisub/commit/19854e207a2f8f703f73791a0a0f887a4a6cd964
[oldver]: https://github.com/torque/Aegisub-Motion/tree/legacy
[docu]: https://github.com/torque/Aegisub-Motion/wiki
[aegplork]: http://plorkyeran.com/aegisub/
[mocha]: http://www.imagineersystems.com/
[gnuplot]: http://www.gnuplot.info/