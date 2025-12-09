const std = @import("std");

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input", .{});
    var read_buf:[1000]u8 = undefined;
    var r = f.reader(std.testing.io, &read_buf);
    var i = &r.interface;
    var last_line : [141]u64 = @splat(0);
    var cur_line :[141]u64 = @splat(0);
    var splits :u64 = 0;

    while(i.takeDelimiter('\n')) |*line| {
        var real_line = line.* orelse break;
        for(real_line, 0..) |char, it| {
            cur_line[it] = char;
        }
        for(0..real_line.len) |it| {
            if(cur_line[it] == '.') cur_line[it] = 0;
            if(cur_line[it] == 'S') cur_line[it] = 1;
        }
        for(0..real_line.len) |it| {
            if(last_line[it] > 0 and cur_line[it] == '^') {
                cur_line[it-1] += last_line[it];
                cur_line[it+1] += last_line[it];
                splits += 1;
            }
            if(cur_line[it] == '^') {
                cur_line[it] = 0;
            } else {
                cur_line[it] += last_line[it];
            }
        }

        for(0..real_line.len) |it| {
            last_line[it] = cur_line[it];
        }
    } else |err| {
        return err;
    }



    std.debug.print("{any}\n", .{last_line});
    std.debug.print("{} splits total\n", .{splits});
    var dimensions:u64 = 0;
    for (last_line) |dim| {
        dimensions += dim;
    }
    std.debug.print("{} dimensions\n", .{dimensions});
}

