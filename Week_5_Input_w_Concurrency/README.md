# Input and/or synchronous concurrency #

We've split this one into parts, the idea being they scale depending on how much time you have/what language you've chosen.

## Part One

Given a file path from the command line, read the file and count the number of lines it contains.

You could:
* Pick one of the string problems from last week to run on the lines.
* Add a command line flags to select the string processing to be run, by default the program will print the number of lines.

This covers:
* Arguments.
* Reading in files.

## Part Two - Concurrency!
Part one but with concurrency!

https://rosettacode.org/wiki/Synchronous_concurrency

Create two concurrent activities ("Threads" or "Tasks", not processes.) that share data synchronously.
One of the concurrent units (the reading unit) will read from a given file and send the contents of that file, one line at a time, to the other concurrent unit (the printing unit), which will print the line it receives to standard output.
The printing unit must count the number of lines it prints, after the reading unit sends its last line to the printing unit, the reading unit will request the number of lines printed by the printing unit, which it will then print (gasp, even though it is a reading unit).

This covers:
* Learning how to create threads.
* Communication between threads (put/get).
* Cleanly terminating the threads.
* Threads.

## "Just for Jim" - More Concurrency

Expand on part two, you could:
* Add a third unit that queries the reading and printing unit to calculate the current progress of the file processing.
* Implement a system such that there is a main thread that organises the two (or more) workers.
