# Boid Simulation

This week we will be simulating flocking birds and schools of fish
by writing a 2D boid simulation following the pseudo code at
http://www.kfish.org/boids/pseudocode.html.

The data/ folder contains a visualiser script that you can use to visualise
the data that you calculate.

The visualiser requires an installation of pygame to work.
If you have a working Python toolchain then this may be as simple as doing:

```bash
pip install pygame
```

You can test the visualiser script using the test data generator as follows:

```bash
python data/test_visualiser_data.py | python data/visualiser.py
```

The visualiser functions as the `draw_boids()` procedure in the pseudo code.
It will read and display the data given to it at the same time that it is passed in.
Therefore it is up to you to control the speed of the data passed in
with a consistent tick rate.

The visualiser visualises binary data given to it from stdin.
It takes a 32 bit unsigned integer representing the number of boids being simulated.
Following this number is, for each frame, the position and velocity of each boid.
The position and velocity are both represented as two 32 bit IEEE 754 floating point numbers,
with the x coordinate first and the y coordinate second.
The coordinate system has (0, 0) in the top left corner of the display window.
The endianness of all numbers matches the native endianness of your hardware.
So for three boids the data that the visualiser expects is
(note that the visualiser expects a constant stream of binary data
and the comments, spaces, and newlines are included for clarity only
and should not be passed to the visualiser):

```
3 -- For three boids
-- Frame 1
0.0 0.0 0.5 0.5 -- boid 1 position and velocity
100.0 200.0 2.0 0.5 -- boid 2 position and velocity
300.0 400.0 0.5 4.0 -- boid 3 position and velocity
-- Frame 2
0.5 0.5 0.5 0.5 -- boid 1 position and velocity
102.0 200.5 0.0 2.0 -- boid 2 position and velocity
300.5 404.0 3.5 1.0 -- boid 3 position and velocity
```

## The Challenge

* Implement rules #1, #2, and #3 described by the pseudo code.
* Bound the position of the boids as described in "Bounding the position".
  The visualiser sets the screens width and height to be 960 * 720.

## Bonuses

* Implement some of the other behaviours described by the pseudo code.
* Implement your own visualiser (Unity people, your time is now!).

## What you will learn

* Working with binary data.
* At this point you know quite a bit of the language
  and can be trying to get used to using your language of choice!
