const std = @import("std");

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input", .{});
    var read_buf:[100]u8 = undefined;
    var r = f.reader(std.testing.io, &read_buf);
    var i = &r.interface;

    var end_at_null: i32 = 0;
    var sum_null: i32 = 0;
    var current_val: i32 = 50;
    
    while(i.takeDelimiter('\n')) |line| {
        const real_line = line orelse break;
        const num : u32 = try std.fmt.parseInt(u32, real_line[1..], 10);
        var direction:i32 = 1;
        if(real_line[0] == 'L') direction = -1;
        for(0..num) |_| {
           current_val = @mod(current_val + direction, 100);
           if(current_val == 0) sum_null += 1;
        }
        if(current_val == 0) end_at_null += 1;
    } else |err| {
        return err;
    }

    std.debug.print("{} stopped at 0\n", .{end_at_null});
    std.debug.print("{} total\n", .{sum_null});
}

