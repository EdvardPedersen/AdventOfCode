const std = @import("std");

const Relation = struct {
    a: Box,
    b: Box,
    dist: f32
};

fn minRelation (context: void, a: Relation, b: Relation) std.math.Order {
    _ = context;
    if(a.dist > b.dist) return .gt;
    if(a.dist < b.dist) return .lt;
    return .eq;
}

const Box = struct {
    x: u32,
    y: u32,
    z: u32,
    

    pub fn distance(self: Box, other: Box) f32 {
        return std.math.sqrt(std.math.pow(f32, @floatFromInt(@as(i64, self.x) - other.x), 2) + 
                             std.math.pow(f32, @floatFromInt(@as(i64, self.y) - other.y), 2) + 
                             std.math.pow(f32, @floatFromInt(@as(i64, self.z) - other.z), 2));
    }
};

pub fn main() !void {
    const f = try std.fs.cwd().openFile("input", .{});
    var read_buf:[100]u8 = undefined;
    var r = f.reader(std.testing.io, &read_buf);
    var i = &r.interface;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var boxes: std.ArrayList(Box) = .{};
    var relations = std.PriorityQueue(Relation, void, minRelation).init(alloc, {});
    var circuits: std.ArrayList(std.AutoHashMap(Box, void)) = .{};

    
    while(i.takeDelimiter('\n')) |line| {
        const real_line = line orelse break;
        const first_i = std.mem.findScalar(u8, real_line, ',') orelse break;
        const second_i = std.mem.findScalarLast(u8, real_line, ',') orelse break;
        const x = try std.fmt.parseInt(u32, real_line[0..first_i], 10);
        const y = try std.fmt.parseInt(u32, real_line[first_i+1..second_i], 10);
        const z = try std.fmt.parseInt(u32, real_line[second_i+1..], 10);
        try boxes.append(alloc, .{.x = x, .y = y, .z = z});
        
    } else |err| {
        return err;
    }
    
    for(0..boxes.items.len) |a| {
        for(a+1..boxes.items.len) |b| {
            var ba = boxes.items[a];
            const bb = boxes.items[b];
            try relations.add(Relation{.a = ba, .b = bb, .dist = ba.distance(bb)});
        }
    }

    //for(0..1000) |_| {
    while(relations.count() > 0) {
        const rel = relations.remove();
        //std.debug.print("{},{},{} - {},{},{} = {}\n", .{rel.a.x, rel.a.y, rel.a.z, rel.b.x, rel.b.y, rel.b.z, rel.dist});
        var found_idx:i64 = -1;
        for(0..circuits.items.len) |idx| {
            if(idx >= circuits.items.len) break;
            if(circuits.items[idx].contains(rel.a)) {
                try circuits.items[idx].put(rel.b, {});
                if(found_idx >= 0 and idx != found_idx) {
                    var iter = circuits.items[idx].keyIterator();
                    while(iter.next()) |key| {
                        try circuits.items[@abs(found_idx)].put(key.*, {});
                    }
                    if(circuits.items[@abs(found_idx)].count() == 1000) std.debug.print("RESULT: {}\n", .{rel.a.x * rel.b.x});
                    _ = circuits.swapRemove(idx);
                }
                found_idx = @intCast(idx);
            }
            if(idx >= circuits.items.len) break;
            if(circuits.items[idx].contains(rel.b)) {
                try circuits.items[idx].put(rel.a, {});
                if(found_idx >= 0 and idx != found_idx) {
                    var iter = circuits.items[idx].keyIterator();
                    while(iter.next()) |key| {
                        try circuits.items[@abs(found_idx)].put(key.*, {});
                    }
                    if(circuits.items[@abs(found_idx)].count() == 1000) std.debug.print("RESULT: {}\n", .{rel.a.x * rel.b.x});
                    _ = circuits.swapRemove(idx);
                }
                found_idx = @intCast(idx);
            }
        }

        if(found_idx >= 0 and found_idx < circuits.items.len) {
            std.debug.print("Len {}\n", .{circuits.items[@abs(found_idx)].count()});
            if(circuits.items[@abs(found_idx)].count() == 1000) {
                const x: u64 = rel.a.x;
                const y: u64 = rel.b.x;
                std.debug.print("RESULT: {}\n", .{x*y});
                break;
            }
            
        }

        if(found_idx < 0) {
            const map = std.AutoHashMap(Box, void).init(alloc);
            try circuits.append(alloc, map);
            try circuits.items[circuits.items.len - 1].put(rel.a, {});
            try circuits.items[circuits.items.len - 1].put(rel.b, {});
        }
    }

    var lengths: []u64 = try alloc.alloc(u64, circuits.items.len);

    for(circuits.items, 0..) |circuit, it| {
        std.debug.print("CURNT {}\n", .{circuit.count()});
        lengths[it] = circuit.count();
    }

    var sum:u64 = 1;
    for(0..3) |_| {
        var max_idx:u64 = 0;
        for(0..circuits.items.len) |it| {
            if(lengths[it] > lengths[max_idx]) max_idx = it;
        }

        sum *= lengths[max_idx];
        lengths[max_idx] = 0;
    }

    std.debug.print("Summed: {}\n", .{sum});
}

