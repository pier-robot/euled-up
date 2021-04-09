# Text Adventure!

 This week we want people to streeeetch their command line skills by making a good old fashioned text adventure. In the data folder you will find a .json file that we handily borrowed from: 
 https://www.smashingmagazine.com/2018/12/multiplayer-text-adventure-engine-node-js/#the-game-json-files

 I'll summarise the gist of it but do check the original link for info! (and a map of the room it is describing)

 This json describes:
 * 6 rooms and how they are connected.
 * The items/NPCs that can be found in each room.
 * The properties of each item/NPC.
 * The game win/lose conditions.

Using this setup implement commands that enable the player to:
* move between rooms.
* look around a room.
* pick up items.
* use items.
* interact with NPCs (in this case, the boss in order to win or lose.)
* exit/reset the game.

As this is an exercise to improve command line skills in your chosen language, do not to use a game loop, the user input should be on the command line, with the game state being saved out and loaded back for each new command.

e.g.
```
>> my_game move south
You're at the entrance of the dungeon.
There are two lit torches on each wall (one on your right and one on your left).
You see only one path: ahead.
>>
>> my_game move south
There is no escape, the door is locked. Coward.
>>
```

Extra:
* add extra arguments to your commands for more complex behaviour.
* add the ability to equip items that affect gameplay, i.e a fancy hat that increases HP.


```
>> my_game search 
There's a bunch of plants all around you but you don't really see anything.
>> my_game search --search-really-hard
You push a monstera aside and pick up the cool cactus behind it and there is a key under the pot!
>>
>> my_game move north --with-style
Sashayed into the boss room. The boss is so impressed he does not attack.
>> my_game use sword --weakly
You feebly try to stab the boss and miss. You have dropped it and hurt yourself.
You have lost 5 hp.
```


<font size="1"> Additional: Don't do any of this and instead play: http://www.noncanon.com/HorseMaster.html<font>
