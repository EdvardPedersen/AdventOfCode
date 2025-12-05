const std = @import("std");

const Range = struct {
    start:u64 = 0,
    stop:u64 = 0,

    fn init(self: *Range, str: []u8, offset: usize) void {
        self.start = std.fmt.parseInt(u64, str[0..offset], 10) catch unreachable;
        self.stop = std.fmt.parseInt(u64, str[offset+1..], 10) catch unreachable;
    }

    fn in(self: Range, num: u64) bool {
        if(num <= self.stop and num >= self.start) return true;
        return false;
    }

    fn remove_overlap(self: *Range, other: *Range) bool {
        if(other.in(self.start)) {
            other.stop = @max(self.stop, other.stop);
            return false;
        }
        if(other.in(self.stop)) {
            other.start = @min(self.start, other.start);
            return false;
        }
        return true;
    }

    fn get_size(self: Range) u64 {
        if(self.start > self.stop) return 0;
        return self.stop + 1 - self.start;
    }
};

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input", .{});
    var read_buf:[100]u8 = undefined;
    var r = f.reader(std.testing.io, &read_buf);
    var i = &r.interface;
    
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();
    var ranges : std.ArrayList(Range) = .{};
    var sum_ingredients:u64 = 0;
    var sum_size:u64 = 0;

    while(i.takeDelimiter('\n')) |line| {
        const real_line = line orelse break;
        const offset = std.mem.find(u8, real_line, "-") orelse 0;
        if(offset > 0) {
            var temp : Range = .{};
            temp.init(real_line, offset);
            var save:bool = true;

            for(ranges.items) |*range| {
                if (!temp.remove_overlap(range)) {
                    save = false;
                    break;
                }
            }

            if(save) try ranges.append(gpa, temp);
            continue;
        }
        if(real_line.len < 1) continue;
        const num : u64 = std.fmt.parseInt(u64, real_line, 10) catch unreachable;
        var num_found : bool = false;
        for(ranges.items) |range| {
            if(range.in(num)){
                num_found = true;
            }
        }
        if(num_found) sum_ingredients += 1;
    } else |err| {
        return err;
    }

    var deduplication = true;
    while(deduplication) {
        deduplication = false;
        for(ranges.items) |*a| {
            for(ranges.items) |*b| {
                if (a != b and !a.remove_overlap(b)) {
                    if(a.start != 0 and a.stop != 0) deduplication = true;
                    a.start = 0;
                    a.stop = 0;
                    break;
                }
            }
        }
    }

    for(ranges.items) |range| {
        if(range.start != 0 and range.stop != 0) {
            std.debug.print("{}-{} size {}\n", .{range.start, range.stop, range.get_size()});
            sum_size += range.get_size();
        }
    }

    std.debug.print("{} ingredients are fresh\n", .{sum_ingredients});
    std.debug.print("{} ingredients are fresh in total\n", .{sum_size});
}

