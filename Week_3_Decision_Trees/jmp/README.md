# Overview

For this project went a bit all out in an attempt to have different
modules working together to try to get a feel for how working with
bigger projects in Zig would be.

# Table of Contents
* [Overview](#overview)
* [The Players](#the-players)
    * [The ATD](#the-atd-random)
    * [The Human](#the-human-you)
    * [The Perfect](#the-perfect-player-newell-and-simons-algorithm)
        * [References](#references)
    * [The Minimax](#the-minimax-with-alpha---beta-pruning)
        * [References](#references-1)
* [Things I Learned About Zig](#things-i-learned-about-zig)
    * [Errors](#errors)
    * [Tests](#tests)
    * [Struct Callbacks](#struct-callbacks)
* [Algorithm Stats](#algorithm-stats)
    * [Raw Data](#raw-data)

## The Players

### The ATD (Random)
This was the first player I created, which randomly fills positions
on the board. This was easy to make and provided a great way to test
out the overall system and benchmark other players against.

### The Human (You)
Building off the guesser game in week one the human accepts CLI input
and allows and uses the numbers to mark positions. Bad input and as 
well as invalid moves are reported.

### The Perfect Player (Newell and Simon's algorithm)
This is the most complicated player as it has a large number of rules
that are followed. Mulitple nested loops looking for various conditions
to find a position to mark or skip and fall through to the next rule.

Finding forks is the most complicated aspect. Building this part was
basically done by TDD. A rough findForks() function was setup then tests
would be written to that findForks() would be compared with that. The ease
of writing tests made it a really fast and pleasant experience.

For example this configuration has 4 possible forks for the x player marked
by their numeric positions.
```
7┃ ┃x 
━╋━╋━
5┃x┃6
━╋━╋━
o┃ ┃2 
```

A simple Zig test to ensure I was finding these positions and choosing
one of the correct positions looks like -
```zig
test "Players: Perfect trap 2" {
    var b = Board.init();
    b.playPosition(Play.x, 4) catch unreachable;
    b.playPosition(Play.o, 0) catch unreachable;
    b.playPosition(Play.x, 8) catch unreachable;

    var perfect = Perfect.init(Play.o, "perfect");
    var forks = perfect.findForks(b, Play.x);
    expect(std.mem.eql(u4, &forks, &[_]u4{ 5, 6, 7, 2 }));
    var pos = perfect.pickPos(b);
    expect(pos == 2 or pos == 7);
}
```

#### References:
* [Newell and Simon's Strategy](https://en.wikipedia.org/wiki/Tic-tac-toe#Strategy)

### The Minimax (with Alpha - Beta Pruning)
This algorithm uses recursion to score all possible moves for both you and
your opponent. The standard implementation is an exhaustive search of every
move possible, however this is a alpha-beta prune optimization where parts of
the tree can be skipped if they score lower, saving significant computational
cost. (See table below.)

#### References:
* [Coding A Perfect Tic-Tac-Toe Bot!](https://medium.com/ai-in-plain-english/coding-the-perfect-tic-tac-toe-bot-a0827e966a74)
* [Optimizing our Perfect Tic-Tac-Toe Bot](https://medium.com/ai-in-plain-english/optimizing-our-perfect-tic-tac-toe-bot-763226eff450)

# Things I Learned About Zig

Overall I got significantly more comfortable with Zig. I'm no longer struggling with
the types or having to think about syntax. However there were three areas that a bit
of time was invested in learning.

## Errors
In previous weeks I just try/catch'd errors and more or less ignored them. This week
I wanted to create and "raise" my own. This was only place errors are returned
is within the board update logic. I wanted to verify that the position wasn't out of bounds and 
was in an empty square.
```zig
/// Play a position on the board, and record it in the list of plays.
pub fn playPosition(self: *@This(), play: Play, pos: u4) BoardError!void {

    if ( pos > 8 ) return error.PositionOffBoard;
    if ( self.positions[pos] != Play.empty ) return error.OccupiedPosition;

    self.positions[pos] = play;
    self.plays[self.turn_num - 1] = BoardPlay{ .position = pos, .play = play };
    self.turn_num += 1;
}
```

Two different errors are returned depending on the condition, `error.PositionOffBoard` and
`error.OccupiedPosition`. You'll notice in the function defintion however we are returning
BoardError. This is a error set that I made, which means this function is only allowed to
return the errors within the BoardError set.
```zig
pub const BoardError = error {
    OccupiedPosition,
    PositionOffBoard,
};
```
This is a handy way of group errors. In this program, these errors are passed the whole
way to main() which will cause the program to halt. (And means I get to write some new
tests.)

## Tests

Mentioned above, writing tests is very quick and easy. You can sprinkle test blocks
through out code, and as long as you point your build script at them, you can do
something like `zig build test` and they'll all run. This also help validate understandings
about the language. For example, I wanted to verify assigning one array to another actually
made a copy (as opposed to copying a reference in Python), so I made a simple test.

```zig
test "General: array copying" {
    var a = [_]u8{1} ** 5;
    var b = a;
    b[3] = 2;
    expect(a[3] == 1);
}
```
As expected, setting the 4th element in array b to 2, doesn't affect array a.

## Struct Callbacks

Zig is strongly typed. Which I love, however it means writing generic code requires more
planning. One example of this is how I designed players.

```zig
var player1 = Perfect.init(board.Play.o, "perfect");
var player2 = ATD.init(board.Play.x, "atd");
```
Here player1 and player2 are two different types, Perfect and ATD. The designed that I
envisioned was I would pass both these players along with a gameboard to a 
`gameLoop(player1, player2, game_board)` function. Within the gameLoop you'd have something like
```zig
    for (game_board.positions) |_, turn| {
        if (whose_turn) {
            try player1.playBoard(game_board);
        } else {
            try player2.playBoard(game_board);
        }
```
Nice and generic, so far so good. Now let's look at our function definition for the gameLoop.
`fn gameLoop(player1: *Perfect, player2: *ATD, game_board: *board.Board) `
Zig is strongly typed, so I need to specify the correct types to the gameLoop. Hmmm. What if I want player1 to
the ATD.
```zig
fn gameLoopPerfectATD(player1: *Perfect, player2: *ATD, game_board: *board.Board)
...
fn gameLoopATDPerfect(player1: *ATD, player2: *Perfect, game_board: *board.Board)
...
if (player1 == @typeOf(Perfect) and player2 == @typeOf(ATD)
    gameLoopPerfectATD(player1, player2);
else if (player1 == @typeOf(ATD) and player2 == @typeOf(Perfect)
    gameLoopATDPerfect(player1, player2);
```
Omg this sucks. So much for being generic. So what can we do?

Each player has a different `playBoard()` implementation.  But what if we had a generic Player struct, 
that instead of implementing it's own `playBoard()` implementation it pointed one of the other player's `playBoard()`
implementations. Not exactly a mixin, but a similar idea.

First let's define our generic Player.
```zig
pub const Player = struct {
    // Play field is whether it's an "x" or "o"
    play: Play,
    // Just a name for the player like "lul720n0scopeRailshotgitgud"
    name: []const u8,
    // This is a field called playBoardFn, but instead of the type being an
    // unsigned int or other "standard" type, the type is actually a function
    // definition. (That's right, function defintions are types too.)
    playBoardFn: fn (player: *Player, game_board: *Board) BoardError!void,

    // And last, we have a function that calls our playBoardFn field defined
    // above.
    pub fn playBoard(self: *Player, game_board: *Board) BoardError!void {
        try self.playBoardFn(self, game_board);
    }
};
```
So what is `playBoardFn`? Well right now it's just a empty variable that needs an implementation.
Guess where we are going to get that implementation? That's right, the other players!

Let's define our ATD,
```zig
pub const ATD = struct {
    // So here we are creating a field of type Player, which is what we defined above.
    // Inside our ATD struct, we have a field to place our generic Player.
    player: Player,

    // for the random number generation.
    rand: std.rand.DefaultPrng,

    /// This function will initialize the ATD, and this is where the magic happens.
    pub fn init(play: Play, name: []const u8) ATD {
        // define the rng seed.
        var seed: u64 = undefined;
        std.os.getrandom(std.mem.asBytes(&seed)) catch |err| {
            std.debug.print("Unable to seed random, defaulting to 0\n", .{});
            seed = 0;
        };

        // Now create the ATD struct and populate all it's fields.
        return ATD{
            // The first field of ATD, is the generic Player, so we have to now define that.
            .player = Player{
                // as above, we assignign the .play field whatever value play is.
                .play = play,
                // same goes for the name.
                .name = name,
                // And here is the magic, defined below is a function called playBoardCallback
                // we are assigning ATD.playBoardCallback to Player.playBoardFn.
                // Which means whenever Player.playBoardFn is called, it's actually calling
                // ATD.playBoardCallback's unique implementation.
                // But how does this playBoardCallback (or playBoardFn) know to how to access
                // data/implementations from a specific instance of ATD? See below!
                .playBoardFn = playBoardCallback,
            },
            .rand = std.rand.DefaultPrng.init(seed),
        };
    }
    
    // This is the last big magic. This is ATD's definition for the playBoardCallback.
    fn playBoardCallback(player: *Player, game_board: *Board) BoardError!void {

        // Remember at this point this function is actually being called from within
        // Player! We can't use our standard @This() because the is only valid at compile
        // time, and we need to determine this at runtime.

        // Now for the most imporatant bit. This is what ties this function to a specific
        // instance of ATD. The @fieldParentPtr does what it says, and it's a bit like
        // Python's super(). Given a type, ATD in this case, a field name and a pointer
        // to that field, find the address of this instance. Which we assign to self.
        const self = @fieldParentPtr(ATD, "player", player);
        
        // Now that self points to the correct ATD instance we can call
        var pos = self.pickPos(game_board.*);
        try game_board.playPosition(player.play, pos);
    }

    // do fancy stuff
    fn pickPos(self: *@This(), game_board: Board) u4 {
        ...
```

With all of that done above, what does that buy us? We'll let's change our gameLoop function
definition to use Player now.

```zig
fn gameLoop(player1: *Player, player2: *Player, game_board: *Board)
```
Well that looks generic, yay. So what does our calling code look like now?
```zig
var player1 = Perfect.init(board.Play.o, "perfect");
var player2 = ATD.init(board.Play.x, "atd");
gameLoop(player1.player, player2.player, board);
```
Now instead of passing Perfect and ATD to the gameLoop, we are passing the same types
```zig
test "Players: Type Tests" {
    var atd = ATD.init(Play.o, "atd");
    var perfect = Perfect.init(Play.o, "perfect");
    var human = Human.init(Play.o, "human");
    var minimax = Minimax.init(Play.o, "minimax", true);
    expect((@TypeOf(atd.player) == @TypeOf(perfect.player)) and
           (@TypeOf(atd.player) == @TypeOf(human.player)) and
           (@TypeOf(atd.player) == @TypeOf(minimax.player)));
}
```



# Algorithm Stats

Various stats when pitted against the ATD (random) player.

The run time is the total for 1,000,000 games.

|Algorithm|Win Rate|Draw Rate|Run Time|
|---------|--------|---------|--------|
| Minimax | 90.0%  | 10.0% | 1:23:23.00 |
| Minimax with Pruning | 90.0% | 10.0% | 5:15.17 |
| Perfect | 92.5% | 7.5% | 0:00.22 | 

Interestingly, despite the Minimax articles labeling it as a "perfect player"
Newell and Simon's algorithm out preformed it by a slight margin in Wins vs Draws
when compared against a Random player. In other words, the Minimax never lost, but
it drawed more, which is basically losing. So between drawing more and being orders
of magnitude slower I'm glad I spent the time implementing the "true" Perfect version.

## Raw Data

### Minimax vs ATD
```
Win Stats:
 minimax: 900382 (90.0%)
 atd: 0 (0.0%)
 Draw: 99618 (10.0%)
 Elapsed (wall clock) time (h:mm:ss or m:ss): 1:23:23.00
```

### Minimax with Pruning vs ATD
```
Win Stats:
 minimax with pruning: 900109 (90.0%)
 atd: 0 (0.0%)
 Draw: 99891 (10.0%)

 Elapsed (wall clock) time (h:mm:ss or m:ss): 5:15.17
```

### Perfect vs ATD
```
Win Stats:
 perfect: 925329 (92.5%)
 atd: 0 (0.0%)
 Draw: 74671 (7.5%)

 Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.22
``` 
