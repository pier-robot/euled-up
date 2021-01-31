const std = @import("std");
const board = @import("board.zig");
const player = @import("players.zig");

pub fn main() anyerror!void {
    var game = board.Board.init();

    var player1 = player.ATD.init(board.Play.x);
    var player2 = player.Human.init(board.Play.o);

    for (game.spaces) |_, turn| {
        if (@mod(turn, 2) == 0) {
            player1.playBoard(&game);
        } else {
            player2.playBoard(&game);
        }
        game.printBoard();

        var winner = game.winnerIs();
        if (winner != board.Play.empty) {
            if ( player1.play == winner ) {
                std.debug.print("Winner is Player #1 ({s})\n", .{player1.name});
            } else {
                std.debug.print("Winner is Player #2 ({s})\n", .{player2.name});
            }
            return;
        }
    }

    if (game.winnerIs() == board.Play.empty) {
        std.debug.print("Draw\n", .{});
        return;
    }

    game.reset();
    std.debug.print("{}\n", .{game.numFreeSpaces()});
}
