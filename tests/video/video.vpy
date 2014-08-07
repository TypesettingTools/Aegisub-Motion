#!/usr/bin/env python3

import vapoursynth as vs

core = vs.get_core( )

outClip = core.std.BlankClip( width=1280, height=720, format=vs.YUV420P8, length=10, fpsnum=24000, fpsden=1001, color=[255, 127, 127] )
subs = core.assvapour.AssRender( outClip, file="video.ass" )
# AssRender returns subs in RGB, so we have to convert them to the same
# colorspace as the video.
subs[0] = core.resize.Bicubic( subs[0], format=vs.YUV420P8 )
outClip = core.std.MaskedMerge( clipa=outClip, clipb=subs[0], mask=subs[1])

outClip.set_output( )

# vspipe -y video.vpy - | x264 --crf 18 --output video.mp4 --demuxer y4m -
