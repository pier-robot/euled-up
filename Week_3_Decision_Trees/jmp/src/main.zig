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

fn game_loop(player1: anytype, player2: anytype, game_board: *board.Board) board.Play {

    game_board.reset();

    for (game_board.positions) |_, turn| {
        if (@mod(turn, 2) == 0) {
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

    var player1 = player.ATD.init(board.Play.x);
    var player2 = player.Human.init(board.Play.o);

    // Start a game loop until the player exits
    while (true) {
    
        var winner = game_loop(&player1, &player2, &game_board);

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
