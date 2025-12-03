const std = @import("std");

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input.data", .{});
    var read_buf:[100]u8 = undefined;
    var r = f.reader(std.testing.io, &read_buf);
    var i = &r.interface;

    var sum_null: i32 = 0;
    var current_val: i32 = 50;
    
    while(i.takeDelimiter('\n')) |line| {
        const real_line = line orelse break;
        const s_dir = real_line[0];
        const s_num = real_line[1..];
        const num = try std.fmt.parseInt(i32, s_num, 10);
        var remaining = @abs(num);
        var direction:i32 = 1;
        if(s_dir == 'L') direction = -1;
        while(remaining != 0) {
           remaining -= 1;
           current_val += direction;
           if(current_val == -1) current_val = 99;
           if(current_val == 100) current_val = 0;
           if(current_val == 0) sum_null += 1;
           
        }
    } else |err| {
        return err;
    }

    std.debug.print("{} total\n", .{sum_null});
}

