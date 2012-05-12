This is the fancy new branch for the fancy new features, as well as reducing some of the bloat I introduced to the script over time.

This branch is not guaranteed to be stable at any time. If you want something that (mostly) works, see [master](https://github.com/torque/Aegisub-Motion/tree/master).

done:

 - independent clip motion
 - multiple override block per line support
 - arbitrary start frame, rather than just first or last.

todo:

 - rewrite the config stuff to actually work

regressions:

 - linear mode completely broken (well, actually, deleted).
 - NO SUPPORT FOR AEGISUB 2.1.X BECAUSE I DON'T LIKE IT

scrapped ideas:

 - manual save (entirely incompatable with the current token system)
 - autostart mocha via command line for love and peace (too lazy to investigate feasibility.)