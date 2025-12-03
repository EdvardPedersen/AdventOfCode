const std = @import("std");

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input", .{});
    var read_buf:[500]u8 = undefined;
    var r = f.reader(std.testing.io, &read_buf);
    var i = &r.interface;
    var joltage : u128 = 0;
    const num_batt:usize = 12;
    
    while(i.takeDelimiter('\n')) |line| {
        const real_line = line orelse break;
        if(real_line.len < 2) break;
        var current_index:usize = 0;
        var values:[num_batt]u8 = undefined;

        for(0..num_batt) |iter| {
            current_index = std.mem.findMax(u8, real_line[current_index..real_line.len - (num_batt - (iter + 1))]) + current_index;
            values[iter] = real_line[current_index];
            current_index += 1;
        }

        const val = try std.fmt.parseInt(u64, &values, 10);
        joltage += val;

    } else |err| {
        return err;
    }

    std.debug.print("Total joltage {}\n", .{joltage});
}

