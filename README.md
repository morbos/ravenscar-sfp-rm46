# ravenscar-sfp-rm46
Port of Adacore's Libre ravenscar library to the RM46 (running in Thumb state)

This is a port of the GPL'd Adacore Ravenscar profile to a Texas Instrument RM46 safety microconroller. Adacore has support 
the TMS570 but not the RM46. Also, in Thumb state, the context switch is slightly different.

To build this code, you need the GNAT compiler. It can be DL'd from libre.adacore.com for ARM targets (you can host on Windows
or Linux). A one stop shopping with an interesting demo can be obtained here:

http://blog.adacore.com/tetris-in-spark-on-arm-cortex-m4

There you can find all the tools (link at bottom of the blog) and a script (start.sh) to setup all the paths to the compiler 
for you

After that, cd into the ravenscar-sfp-rm46 dir and:

gprbuild

The upshot is a libgnat.a that can be used with examples. (to follow in another commit)

Hedley
