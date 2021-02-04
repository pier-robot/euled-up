//! Main entry point for the tic-tac-toe

const std = @import("std");

const board = @import("board.zig");
const player = @import("players.zig");
const utils = @import("utils.zig");

const game_limit: u32 = 1_000_000;

const Stats = struct {
    player1: u32,
    player2: u32,
    draw: u32,
};

fn game_loop(player1: *player.Player, player2: *player.Player, game_board: *board.Board, quiet: bool) board.Play {
    game_board.reset();
    if (!quiet) game_board.printBoard(true);

    var x_start_offset: u8 = undefined;

    // x always goes first, so we use a offset to control which
    // player is associated with x.
    if (player1.play == board.Play.x) {
        x_start_offset = 0;
    } else {
        x_start_offset = 1;
    }

    for (game_board.positions) |_, turn| {
        if (@mod(turn, 2) == x_start_offset) {
            player1.playBoard(game_board);
        } else {
            player2.playBoard(game_board);
        }
        if (!quiet) game_board.printBoard(true);

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

    var game_wins = Stats{
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

    // TODO add opponent selector
    var player1 = player.Perfect.init(board.Play.o, "perfect");
    //var player1 = player.Minimax.init(board.Play.o, "minimax", false);
    //var player1 = player.Minimax.init(board.Play.o, "minimax with pruning", true);
    var player2 = player.ATD.init(board.Play.x, "atd");
    // var player2 = player.Human.init(board.Play.x, "human");

    // Is there a human? If not be quiet.
    var quiet = true;
    if (@TypeOf(player1) == @TypeOf(player.Human) or @TypeOf(player2) == @TypeOf(player.Human))
        quiet = false;

    var game_counter: u32 = 0;

    // Start a game loop until the player exits
    while (game_counter < game_limit) {

        // Randomly pick who goes first (x)
        if (rand.boolean()) {
            player1.player.play = board.Play.x;
            player2.player.play = board.Play.o;
        } else {
            player1.player.play = board.Play.o;
            player2.player.play = board.Play.x;
        }

        // NOTE:
        // If we don't take the address of player then we are just
        // creating a Player type that is not associated with the
        // wrapping Struct (ATD or Human, etc)
        var winner = game_loop(&player1.player, &player2.player, &game_board, quiet);

        if (winner == player1.player.play) {
            if (!quiet) std.debug.print("Winner is {s}\n", .{player1.player.name});
            game_wins.player1 += 1;
        } else if (winner == player2.player.play) {
            if (!quiet) std.debug.print("Winner is {s}\n", .{player2.player.name});
            game_wins.player2 += 1;
            game_board.printPlays(true);
            break;
        } else {
            if (!quiet) std.debug.print("Draw\n", .{});
            game_wins.draw += 1;
        }

        if (!quiet) {
            std.debug.print("\nWin Stats:\n" ++
                " {s}: {}\n" ++
                " {s}: {}\n" ++
                " Draws: {}\n", .{ player1.player.name, game_wins.player1, player2.player.name, game_wins.player2, game_wins.draw });
        }

        if (!quiet) {
            std.debug.print("\nPress 'q' to quit or any other key to continue", .{});

            var input = utils.readInput();
            if (std.ascii.eqlIgnoreCase(input, "q")) break;
        }

        //if (game_counter % 10000 == 0 and game_counter > 1 ) 
        //    std.debug.print("{}\n", .{game_counter});
        game_counter += 1;
    }

    var total_games = game_wins.player1 + game_wins.player2 + game_wins.draw;
    var player1_pct = @intToFloat(f64, game_wins.player1) / @intToFloat(f64, total_games) * 100.0;
    var player2_pct = @intToFloat(f64, game_wins.player2) / @intToFloat(f64, total_games) * 100.0;
    var draw_pct = @intToFloat(f64, game_wins.draw) / @intToFloat(f64, total_games) * 100.0;
    std.debug.print("\nWin Stats:\n", .{});
    std.debug.print(" {s}: {} ({d:.1}%)\n", .{ player1.player.name, game_wins.player1, player1_pct });
    std.debug.print(" {s}: {} ({d:.1}%)\n", .{ player2.player.name, game_wins.player2, player2_pct });
    std.debug.print(" Draw: {} ({d:.1}%)\n", .{ game_wins.draw, draw_pct });
}
