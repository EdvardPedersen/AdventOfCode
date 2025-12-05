const std = @import("std");

const Data = struct {
    var data = @embedFile("input");
    cols: usize = 0,
    rows: usize = 0,
    new_data: []u8 = undefined,
    old_data: []u8 = undefined,
    

    pub fn init(self: *Data) void {
        self.cols = std.mem.findScalar(u8, Data.data, '\n') orelse @panic("No newlines in input");
        self.cols += 1;
        self.rows = Data.data.len / self.cols;
        var alloc = std.heap.GeneralPurposeAllocator(.{}){};
        var lla = alloc.allocator();
        self.new_data = lla.dupe(u8, Data.data) catch @panic("OOM");
        self.old_data = lla.dupe(u8, Data.data) catch @panic("OOM");
    }

    pub fn at(self: Data, x: i32, y: i32) u8 {
        if((x > self.cols - 2) or (y > self.rows - 1)) {
            return '.';
        }
        if(y < 0 or x < 0) {
            return '.';
        }
        const ux:usize = @intCast(x);
        const uy:usize = @intCast(y);
        const offset:u64 = uy * self.cols + ux;
        if(offset > self.old_data.len) {
            return '.';
        }
        return self.old_data[uy * self.cols + ux];
    }

    pub fn remove_roll(self: *Data, x: usize, y: usize) void {
        const offset:usize = y * self.cols + x;
        self.new_data[offset] = '.';
    }

    pub fn update_data(self: *Data) void {
        @memcpy(self.old_data, self.new_data);
    }

    pub fn print_fully(self: Data) void {
        for(0..self.rows) |y| {
            for(0..self.cols) |x| {
                std.debug.print("{c}", .{self.at(x, y)});
            }
        }
        std.debug.print("\n", .{});
    }
};

pub fn main() !void {
    var data: Data = .{};
    data.init();
    var rolls: u64 = 0;
    var removed_last: u64 = 1;

    while(removed_last > 0) {
        removed_last = 0;
        for(0..data.rows) |y| {
            for(0..data.cols - 1) |x| {
                var neighbours:u8 = 0;
                const current : u8 = data.at(@intCast(x), @intCast(y));
                for(0..3) |off_y| {
                    const r_y:i32 = @as(i32, @intCast(y + off_y)) - 1;
                    
                    for(0..3) |off_x| {
                        const r_x:i32 = @as(i32, @intCast(x + off_x)) - 1;
                        //std.debug.print("{} {} {c}\n", .{r_x, r_y, data.at(r_x, r_y)});
                        if(data.at(r_x, r_y) != '.' and !(r_x == x and r_y == y)) neighbours += 1; 
                    }
                }

                if(neighbours < 4 and current == '@') {
                    removed_last += 1;
                    rolls += 1;
                    data.remove_roll(x, y);
                }
            }
        }
        data.update_data();
    }
    std.debug.print("Rolls: {}\n", .{rolls});
}

