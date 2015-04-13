### Aegisub-Motion.moon ###

##### [PLEASE REPORT BUGS YOU ENCOUNTER](#help-i-need-somebody-help-not-just-anybody)

#### v1.0.0 ####

The dream is real.

#### What do I need to use this? ####

 - Aegisub 3.2.x or any future release that doesn't break everything.
 - Motion tracking software, such as [Blender][blender] or [Mocha Pro][mochapro].
 - Too much goddamn free time.

#### How do I install it? ####

The recommended method is to use [DependencyControl][depctrl]. If you
cannot use DependencyControl, however, release zips are provided. Note
that the release zip versions will still use DependencyControl for
automatic updating if it is available.

#### Installing with DependencyControl
Installation instructions for DependencyControl can be found [here](DCInst).

- Save [this copy of Aegisub-Motion.moon][amodep] to your automation autoload directory. Make sure it is named `a-mo.Aegisub-Motion.moon`.
- Either run Aegisub or reload all automation scripts. All modules should be automatically updated to their latest versions.

#### Installing from a release zip

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

I fully recommend finding something better to waste your time.

#### Help! I need somebody! Help! Not just anybody! ####

If you use IRC, I'm `torque` on `freenode` and `rizon`. Feel free to ask
questions. Also, this repository has an [issues page][issues] if you
want to be formal about it.

[blender]: http://www.blender.org/
[mochapro]: http://www.imagineersystems.com/products/mocha-pro/
[legacy]: https://github.com/TypesettingTools/Aegisub-Motion/tree/legacy
[depctrl]: https://github.com/TypesettingTools/DependencyControl
[DCInst]: https://github.com/TypesettingTools/DependencyControl#install-instructions
[amodep]: https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/Aegisub-Motion.moon
[releases]: https://github.com/TypesettingTools/aegisub-motion/releases
[wiki]: https://github.com/TypesettingTools/aegisub-motion/wiki
[twitter]: https://twitter.com/a_rinwe
[issues]: https://github.com/TypesettingTools/aegisub-motion/issues
