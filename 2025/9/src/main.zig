const std = @import("std");

const Tile = struct {
    x:u32,
    y:u32,
};

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input", .{});
    var read_buf:[100]u8 = undefined;
    var r = f.reader(std.testing.io, &read_buf);
    var i = &r.interface;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var tiles: std.ArrayList(Tile) = .{};
    
    while(i.takeDelimiter('\n')) |line| {
        const real_line = line orelse break;
        const comma = std.mem.findScalar(u8, real_line, ',') orelse break;
        const x = try std.fmt.parseInt(u32, real_line[0..comma], 10);
        const y = try std.fmt.parseInt(u32, real_line[comma+1..], 10);
        try tiles.append(alloc, .{.x = x, .y = y});
        
    } else |err| {
        return err;
    }

    var max_area : u64 = 0;

    for(0..tiles.items.len) |a| {
        for(a..tiles.items.len) |b| {
            const a_tile = tiles.items[a];
            const b_tile = tiles.items[b];
            const xdiff:u64 = @max(a_tile.x, b_tile.x) - @min(a_tile.x, b_tile.x) + 1;
            const ydiff:u64 = @max(a_tile.y, b_tile.y) - @min(a_tile.y, b_tile.y) + 1;
            const area:u64 = xdiff * ydiff;
            if(area > max_area) {
                max_area = area;
            }
        }
    }

    std.debug.print("Max area: {}\n", .{max_area});
}

