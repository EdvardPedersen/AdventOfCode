const std = @import("std");

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input", .{});
    var read_buf:[10000]u8 = undefined;
    var r = f.reader(std.testing.io, &read_buf);
    var i = &r.interface;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var rows: std.ArrayList(std.ArrayList(i32)) = .{};
    var operations : std.ArrayList(u8) = .{};
    
    while(i.takeDelimiter('\n')) |line| {
        const real_line = line orelse break;
        const simple_line = std.mem.collapseRepeats(u8, real_line, ' ');
        var iter = std.mem.tokenizeScalar(u8, simple_line, ' ');
        var new = try rows.addOne(alloc);
        new.* = .{};
        
        while(iter.next()) |word| {
            const new_val = std.fmt.parseInt(i32, word, 10) catch {
                try operations.append(alloc, word[0]);
                continue;
            };
            try new.append(alloc, new_val);
        }
        if(new.items.len < 2) _ = rows.pop();
    } else |err| {
        return err;
    }

    var results : []i64 = try alloc.alloc(i64, operations.items.len);
    @memset(results, -1);

    for(operations.items, 0..) |op, num| {
        for(rows.items) |row| {
            if(results[num] == -1) {
                results[num] = row.items[num];
            } else {
                if(op == '+') results[num] += row.items[num];
                if(op == '*') results[num] *= row.items[num];
            }
        }
    }

    var final : i64 = 0;
    for(results) |item| {
        final += item;
    }
    std.debug.print("{} is sum\n", .{final});
}

