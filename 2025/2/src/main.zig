const std = @import("std");

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input", .{});
    var read_buf:[100]u8 = undefined;
    var r = f.reader(std.testing.io, &read_buf);
    var i = &r.interface;

    var total_invalid : u128 = 0;
    
    while(i.takeDelimiter(',')) |line| {
        const t_line = line orelse break;
        const r_line = std.mem.trimEnd(u8, t_line, "\n");
        const splitter = std.mem.findScalar(u8, r_line, '-') orelse break;
        const start = try std.fmt.parseInt(u64, r_line[0..splitter], 10);
        const end = try std.fmt.parseInt(u64, r_line[splitter+1..], 10);

        var buf:[100]u8 = undefined;
        for(start..end+1) |cur| {
            const str = try std.fmt.bufPrint(&buf, "{}", .{cur});
            if(str.len < 2) continue;
            const max_mid : u64 = @max(@divFloor(str.len, 2), 1);
            for(1..max_mid+1) |span| {
                if(str.len % span != 0) continue;
                const num_strings = str.len / span;
                if(std.mem.containsAtLeast(u8, str, num_strings, str[0..span])) {
                    std.debug.print("Invalid: {s}\n", .{str});
                    total_invalid += cur;
                    break;
                }
            }
        }
    } else |err| {
        return err;
    }

    std.debug.print("{} invalid sum\n", .{total_invalid});
}

