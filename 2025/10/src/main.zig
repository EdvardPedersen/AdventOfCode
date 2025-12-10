const std = @import("std");

const Machine = struct {
    target: std.bit_set.IntegerBitSet(32),
    numbers: []std.bit_set.IntegerBitSet(32),
};

pub fn get_xor(indices:[]u8, available: []std.bit_set.IntegerBitSet(32)) std.bit_set.IntegerBitSet(32) {
    var res: std.bit_set.IntegerBitSet(32) = .{.mask = 0};
    for(indices) |idx| {
        res = res.xorWith(available[idx]);
    }
    return res;
}

pub fn factorial(num: u64) u64 {
    var r:u64 = 1;
    for(1..(num+1)) |i| {
        r *= i;
    }
    return r;
}

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input", .{});
    var read_buf:[1000]u8 = undefined;
    var r = f.reader(std.testing.io, &read_buf);
    var i = &r.interface;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var machines: std.ArrayList(Machine) = .{};
    
    while(i.takeDelimiter('\n')) |line| {
        const real_line = line orelse break;
        const start = std.mem.find(u8, real_line, "[") orelse break;
        const stop = std.mem.find(u8, real_line, "]") orelse break;
        const target = real_line[start + 1..stop];
        var targ: std.bit_set.IntegerBitSet(32) = .{.mask = 0};
        for(0..target.len) |idx| {
            if(target[idx] == '#') targ.set(idx);
        }

        const num_coord = std.mem.count(u8, real_line, "(");
        var machine = try alloc.create(Machine);
        machine.target = targ;
        machine.numbers = try alloc.alloc(std.bit_set.IntegerBitSet(32), num_coord);
        var iter = std.mem.splitScalar(u8, real_line[stop+1..], ' ');
        var counter:u32 = 0;
        while(iter.next()) |word| {
            if(std.mem.startsWith(u8, word, "(")) {
                if(counter >= machine.numbers.len) break;
                machine.numbers[counter].mask = 0;
                var inneriter = std.mem.splitScalar(u8, word[1..word.len - 1], ',');
                while(inneriter.next()) |coord| {
                    const num = try std.fmt.parseInt(u32, coord, 10);
                    machine.numbers[counter].set(num);
                }
                counter += 1;
            } else if(std.mem.startsWith(u8, word, "{")) {
                break;
            }
        }
        try machines.append(alloc, machine.*);
        
    } else |err| {
        return err;
    }

    var sum: usize = 0;

    for(machines.items) |machine| {
        machine_tag: for(0..machine.numbers.len) |len| {
            const num_items = factorial(machine.numbers.len) / (factorial(len+1) * factorial(machine.numbers.len - (len+1)));
            var combinations = try alloc.alloc([]u8, num_items);
            var min_nums: []u8 = try alloc.alloc(u8, len + 1);
            for(0..min_nums.len) |it| {
                min_nums[it] = @truncate(it);
            }
            for(0..combinations.len) |it| {
                combinations[it] = try alloc.alloc(u8, len + 1);
                for(0..min_nums.len) |innerit| {
                    combinations[it][innerit] = min_nums[innerit];
                }
                
                min_nums[min_nums.len - 1] += 1;

                var done = false;
                while(!done) {
                    done = true;
                    for(1..min_nums.len) |innerit| {
                        const offset = min_nums.len - innerit;
                        if(min_nums[offset] >= machine.numbers.len) {
                            min_nums[offset - 1] += 1;
                            for(offset..min_nums.len) |suboff| {
                                min_nums[suboff] = min_nums[suboff - 1] + 1;
                            }
                            if(min_nums[offset] <= machine.numbers.len) done = false;
                        }
                    }
                }
            }

            for(combinations) |combo| {
                const result = get_xor(combo, machine.numbers).mask;
                if(result == machine.target.mask) {
                    sum += combo.len;
                    break :machine_tag;
                }
            }
            
        }
    }

    std.debug.print("{} ops\n", .{sum});
}

