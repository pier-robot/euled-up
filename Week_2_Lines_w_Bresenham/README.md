# Week 2 - Lines with Bresenham

Second problem:
http://rosettacode.org/wiki/Bitmap/Bresenham%27s_line_algorithm

Write a basic line renderer that outputs to the terminal:

* You can store the points and lines in memory (maybe even in a read only constant!)
* Do the intermediate calculation of the final image in a simple frame buffer.
* You can assume a terminal (and buffer) of constant size and that the points fit in it.

Bonus points:
* Use 3D lines and do a basic orthographic projection to 2D space.
* Scale the points to fit the size of the fixed frame size.

We like this one because it covers:

* Defining lists, changing their contents
* Conditional loops
* Tuples and/or basic classes to store the points and lines

You'll also be building on the concepts that you learned this week:

* Compiling a program
* Variables syntax
* Outputting to the terminal
* Numeric comparisons