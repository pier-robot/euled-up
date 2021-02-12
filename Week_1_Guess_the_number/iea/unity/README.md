# Guess Number

Attempt of an FPS approach to the guess number problem.
Targets floating around the player are the valid options;
the player, who can only change rotate the view, shoots at them.

If the guess is correct some fireworks spawn from the 
correct target. Otherwise we log debug (for now) to try harder.. 

![](guess_number.gif)

## Note

Technically this Unity project requires the ``TextMesh Pro`` plugin which
can be added to the project via Window > Package Manager.
Once the plugin is imported, the ``pfTarget`` prefab, which is the
asset that uses it might need some adjustments in the corresponding
component for the text size/colour to be the right one.
