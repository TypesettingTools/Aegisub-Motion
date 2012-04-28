This is the fancy new branch for the fancy new features, as well as reducing some of the bloat I introduced to the script over time.

This branch is not guaranteed to be stable at any time. If you want something that (mostly) works, see [master](https://github.com/torque/Aegisub-Motion/tree/master).

done:

 - independent clip motion
 - arbitrary start frame, rather than just first or last.

todo:

 - multiple override block per line support
 - add the clip stuff to the config
 - autostart mocha via command line for love and peace (may not actually happen, as the command window opened by lua may block aegisub-motion (and therefore aegisub) until mocha is closed, which would be fairly undesirable)

regressions:

 - linear mode completely broken (well, actually, deleted).
 - NO SUPPORT FOR AEGISUB 2.1.X BECAUSE I DON'T LIKE IT

scrapped ideas:

 - manual save (entirely incompatable with the current token system)