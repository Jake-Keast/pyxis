# pyxis
Pyxis is a CPU Render Engine that utilises Monte Carlo Ray Tracing, written in Zig. This was a just for fun project I took on in order to build an understanding of the Zig language and to learn about ray tracing. This is a rewrite of an older version of a test render engine I programmed in Zig, as that was very messy and didn't allow for new materials or positionable cameras

The program is invoked by "zig run src/main.zig | bzip2 > FILENAME.ppm.bz2". Its clunky, but the ppm file format was the easiest to work with.

## TODO
- Defocus Blur
- Lights
- Triangles
- Surface Textures
- Solid Textures
- Parallelism and Multithreading
