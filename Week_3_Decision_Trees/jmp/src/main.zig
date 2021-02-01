//! Main entry point for the tic-tac-toe

const std = @import("std");

const board = @import("board.zig");
const player = @import("players.zig");
const utils = @import("utils.zig");

const Stats = struct {
    player1 : u32,
    player2 : u32,
    draw : u32,
};

fn game_loop(
    player1: *player.Player, 
    player2: *player.Player,
    game_board: *board.Board) board.Play {

    game_board.reset();
    game_board.printBoard();

    var x_start_offset: u8 = undefined;
    if ( player1.play == board.Play.x ) {
        x_start_offset = 0;
    } else {
        // player 2 is X and thus goes first.
        x_start_offset = 1;
    }

    for (game_board.positions) |_, turn| {
        if (@mod(turn, 2) == x_start_offset) {
            player1.playBoard(game_board);
        } else {
            player2.playBoard(game_board);
        }
        game_board.printBoard();

        // There can't be a winner until at least 5 iterations
        if (turn < 4) continue;

        var winner = game_board.winnerIs();
        if (winner != board.Play.empty) {
            return winner;
        }
    }

    // If no winner after all possible turns, must be a draw.
    return board.Play.empty;
}

pub fn main() anyerror!void {

    // Game setup
    var game_board = board.Board.init();

    var game_wins = Stats {
        .player1 = 0,
        .player2 = 0,
        .draw = 0,
    };

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = &prng.random;
    
    var player1: *player.Player = undefined;
    var player2: *player.Player = undefined;

    // Start a game loop until the player exits
    while (true) {

        var player1_shape = board.Play.o;
        var player2_shape = board.Play.x;
        // Randomly pick who goes first (x)
        if (rand.boolean()) {
            player1_shape = board.Play.x;
            player2_shape = board.Play.o;
        }

        // NOTE:
        // If we don't take the address of player then we are just
        // creating a Player type that is not associated with the
        // wrapping Struct (ATD or Human, etc)
        player1 = &player.ATD.init(player1_shape, "atd").player;
        player2 = &player.Human.init(player2_shape, "human").player;
    
        var winner = game_loop(player1, player2, &game_board);

        if ( winner == player1.play) {
            std.debug.print("Winner is Player #1 ({s})\n", .{player1.name});
            game_wins.player1 += 1;
        } else if (winner == player2.play) {
            std.debug.print("Winner is Player #2 ({s})\n", .{player2.name});
            game_wins.player2 += 1;
        } else {
            std.debug.print("Draw\n", .{});
            game_wins.draw += 1;
        }

        std.debug.print("\nWin Stats:\n Player 1: {}\n Player 2: {}\n Draws: {}\n", 
            .{game_wins.player1, game_wins.player2, game_wins.draw});

        std.debug.print("\nPress 'q' to quit or any other key to continue", .{});
        var input = utils.readInput();
        if (std.ascii.eqlIgnoreCase(input, "q")) {
            break;
        }

    }
}
