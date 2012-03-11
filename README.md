Aegisub-Motion.lua
------------------

Aegisub-Motion.lua, from here on referred to by vague pronouns such as it or this, is an Automation 4 script for [Aegisub](http://www.aegisub.org/), that provides a set of macros (well, really just two at the moment) to facilitate converting basic motion tracking data into Advanced Substation Alpha override tags.

### Usage ###

Aegisub-Motion is best suited to be used with the 3.0.0 branch of Aegisub, currently trunk. While it is still under heavy development, there are [windows binary snapshots](http://plorkyeran.com/aegisub/) available from one of the developers (note that they are not always incredibly stable). 3.0.0 has added a number of improvements/enhancements to the Aegisub-Automation interface that allow more flexibility, and Aegisub-Motion attempts to make use of a good number of them.

It should still work with the 2.1.X branch of Aegisub (current stable), though some functions may be crippled. I do no testing with 2.1.X, but if you run into any problems, feel free to report them to me. The script also has not been (officially) tested on a *nix operating system, though I have attempted to make it compatable (I think). 

### Features ###

Currently, Aegisub-Motion supports modifying a line's position, scale, and rotation according to user input. It is also capable of modifying those three attributes of an accompanying `\\i?clip()`, to make it change with the line. If a line contains transforms, then they will be segmented across the output lines to make the transform effect appear correctly. It should have full support for vfr video sources, because all of its time calculations get frame timestamps directly from Aegisub.

It sports a semi-advanced post-processing cleanup function that removes duplicate tags, cleans up override blocks, and cleans up transform tags that have already completed or have yet to start. It will also join lines that are identical, so if there are no changes made between two lines, they will be merged together.

The output can be sorted by one of two methods: the default, which is to place each tracked line sequentially after its source line, and by time, which sorts the output lines by their start time.

The second macro can trim and encode the current scene to an H.264-in-mp4 file ready for motion tracking. It requires [x264](http://www.videolan.org/developers/x264.html) to do this.

It uses a very simple external configuration file to save user input across scripts. Unfortunately, the configuration writing functions are not safe, and if an error occurs during them, the entire config script can be erased. Fortunately, this shouldn't happen under normal circumstances.

Finally, it also supports exporting the tracking data into a format that is compatable with [gnuplot](http://www.gnuplot.info/), along with gnuplot plotting instructions. It can even plot the data automatically, if you have gnuplot in your PATH.

### Acknowledgements ###

Many bugs have been reported by various users, and if you've reported something that I've managed to fix, thank you. I'd like to thank tophf and tp7 in particular for both finding many bugs as well as suggesting several of useful new features. I'd also like to thank Plorkyeran for listing to several of my crazy suggestions about expanding aegisub's Automation capabilities.

### Contact ###

I'm typically available as `torque` on `irc.rizon.net`. Feel free to PM me with suggestions, requests or questions.