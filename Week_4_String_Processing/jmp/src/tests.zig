const std = @import("std");

test "Samples: first word" {

    const sentence = "This is an example.";
    var idx: usize = 0;
    for (sentence) |c,i| {
        if (! std.ascii.isAlpha(c) ) {
           idx = i;
            break;
        }
    }
    std.testing.expect(std.mem.eql(u8, "This", sentence[0..idx]));
    std.testing.expect(std.mem.startsWith(u8, sentence, "This"));
}
