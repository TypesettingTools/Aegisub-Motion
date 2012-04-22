Aegisub-Motion.lua
------------------

Aegisub-Motion.lua, from here on referred to by vague pronouns such as “it” or “this”, is an Automation 4 script for [Aegisub](http://www.aegisub.org/), that provides a set of macros (well, really just two at the moment) to facilitate converting basic motion tracking data into Advanced Substation Alpha override tags.

### Usage ###

Aegisub-Motion is best suited to be used with the 3.0.0 branch of Aegisub, currently trunk. While it is still under heavy development, there are [windows binary snapshots](http://plorkyeran.com/aegisub/) available from one of the developers (note that they are not always incredibly stable). 3.0.0 has added a number of improvements/enhancements to the Aegisub-Automation interface that allow more flexibility, and Aegisub-Motion attempts to make use of a good number of them.

It should still work with the 2.1.X branch of Aegisub (current stable), though some functions may be crippled. I do no testing with 2.1.X, but if you run into any problems, feel free to report them to me. The script also has not been (officially) tested on a *nix operating system, though I have attempted to make it compatable (I think).

The input motion data must be of the format `Adobe After Effects 6.0 Keyframe Data` (For Mocha, export to `After Effects Transform Data [anchor point, position, scale and rotation](*.txt)`), which looks like this:

    Adobe After Effects 6.0 Keyframe Data
    
    	Units Per Second	23.976
    	Source Width	1920
    	Source Height	1080
    	Source Pixel Aspect Ratio	1
    	Comp Pixel Aspect Ratio	1
    
    Anchor Point
    	Frame	X pixels	Y pixels	Z pixels
    	0	1583	180	0
    
    Position
    	Frame	X pixels	Y pixels	Z pixels
    	0	1583	180	0
    
    Scale
    	Frame	X percent	Y percent	Z percent
    	0	100	100	100
    
    Rotation
    	Frame	Degrees
    	0	0
    
    End of Keyframe Data

### Features ###

Currently, Aegisub-Motion supports modifying a line's position, scale, and rotation according to user input. It is also capable of modifying those three attributes of an accompanying `\\i?clip()`, to make it change with the line. If a line contains transforms, then they will be segmented across the output lines to make the transform effect appear correctly. It should have full support for vfr video sources, because all of its time calculations get frame timestamps directly from Aegisub.

It sports a semi-advanced post-processing cleanup function that removes duplicate tags, cleans up override blocks, and cleans up transform tags that have already completed or have yet to start. It will also join lines that are identical, so if there are no changes made between two lines, they will be merged together.

The output can be sorted by one of two methods: the default, which is to place each tracked line sequentially after its source line, and by time, which sorts the output lines by their start time.

The second macro can trim and encode the current scene to an H.264-in-mp4 file or an image sequence ready for motion tracking. It can utilize x264, ffmpeg, avisynth, or potentially many other command-line tools to do this (ffmpeg is not frame accurate, and avisynth needs ffms2 or another frame accurate source filter to be, well, frame accurate.)

It uses a very simple external configuration file to save user input across scripts. The config writing functions should no longer be capable of erasing the contents of config file if they error.

Finally, it also supports exporting the tracking data into a format that is compatable with [gnuplot](http://www.gnuplot.info/), along with gnuplot plotting instructions. It can even plot the data automatically, if you have gnuplot in your PATH.

### Acknowledgements ###

Many bugs have been reported by various users, and if you've reported something that I've managed to fix, thank you. I'd like to thank tophf and tp7 in particular for both finding many bugs as well as suggesting several of useful new features. I'd also like to thank Plorkyeran for listening to several of my crazy suggestions about expanding aegisub's Automation capabilities.

### Contact ###

I'm typically available as `torque` on `irc.rizon.net`. Feel free to PM me with suggestions, requests or questions.