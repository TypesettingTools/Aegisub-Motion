LoadCPlugin("assrender.dll")
BlankClip(length=500,width=1280,height=720,fps=23.976,color=$FFFFFF).converttoyv12() #assrender does not work properly on rgb.
assrender("test-video.ass")