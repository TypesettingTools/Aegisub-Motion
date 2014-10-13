### Aegisub-Motion.moon ###

#### v1.0.0 Test 10 ####

Aegisub-Motion has been rewritten from the ground up to be even slower
and more error prone than ever before.

Just kidding, that didn't happen intentionally. I'm just incompetent.

#### What do I need to use this? ####

 - Aegisub 3.2.x or any future release that doesn't break everything.
 - Motion tracking software, such as [Blender][blender] or [Mocha Pro][mochapro].
 - Too much goddamn free time.

#### The legacy version is available [here][legacy]

As there are numerous new features and changes being made, the 1.0.0
pre-releases are not rigorously tested and may have bugs affecting
needed behavior.

Additionally, the legacy version supports older versions of Aegisub (I
think 3.0.0 and newer but maybe only 3.1.0 and newer).

Except for the conflicting filenames, the two scripts should be able to
be installed and loaded simultaneously.

The legacy version will receive NO MAINTENANCE OR UPDATES.

#### How do I install it? ####

What you probably want to do is to install one of [the
releases][releases]. Due to the way the code is now laid out, installing
isn't as trivial as dragging a single file into a folder. The releases
have easy-to-follow instructions included. They are reproduced here for
your convenience:

#### Installation Instructions ([from a release zip][releases])

##### Windows (Installed Aegisub)

- Open `%appdata%\Aegisub`. You can do this by opening an explorer window and typing it in the breadcrumb.
- In the folder you just opened, verify that there is an `automation` directory. If there is not, create it.
- If you just created an `automation` directory, copy the `autoload` and `include` folders from this zip to the directory you just created.
- If the `autoload` and `include` folders already exist, copy their contents in the zip into the those folders.

##### Windows (Portable Aegisub)

- Find your Aegisub folder. In it should be an `automation` folder.
- In the `automation` folder, copy the contents of the zip's `autoload` and `include` folders into the respective folders in your `Aegisub/automation` folder.

##### OS X

- In a Finder window, press `cmd+shift+g`, and enter `~/Library/Application Support/Aegisub/` into the dropdown window.
- In the folder you just opened, verify that there is an `automation` directory. If there is not, create it.
- If you just created an `automation` directory, copy the `autoload` and `include` folders from this zip to the directory you just created.
- If the `autoload` and `include` folders already exist, copy their contents in the zip into the those folders.

##### Linux

- Copy the files into `~/.aegisub/automation`. You may need to create these directories.

If you absolutely MUST install from git, I'll let you figure that one
out yourself.

#### How do I use this? ####

It should be pretty much the same as the old version. I'm currently
working on writing up some brand-spanking-new documentation to accompany
the 1.0.0 release.

#### Help! I need somebody! Help! Not just anybody! ####

##### PLEASE REPORT BUGS YOU ENCOUNTER

I am here to fulfill your emotional and physical needs 24/7, 52 weeks a
year. If you use IRC, I'm `torque` on `freenode` and `rizon`. If you use
twitter, I'm [`@a_rinwe`][twitter]. Also, this repository has an [issues
page][issues] if you want to be formal about it. If you don't use any of
those things, too bad!

[blender]: http://www.blender.org/
[mochapro]: http://www.imagineersystems.com/products/mocha-pro/
[legacy]: https://github.com/torque/Aegisub-Motion/tree/legacy
[releases]: https://github.com/torque/aegisub-motion/releases
[wiki]: https://github.com/torque/aegisub-motion/wiki
[twitter]: https://twitter.com/a_rinwe
[issues]: https://github.com/torque/aegisub-motion/issues
