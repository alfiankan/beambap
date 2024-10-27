const std = @import("std");

pub const Opcodes = enum(u8) {
    NOP = 0,
    STORE = 1,
    PUSH = 2,
    ADD = 3,
    POP = 4,
    CMP_LT = 5,
    SYSCALL = 6,
    LOAD = 7,
};

const Instruction = struct {
    opcode: Opcodes,
    args: [3]u32,
};

pub const BeamBapRuntime = struct {
    pub fn init() BeamBapRuntime {
        return BeamBapRuntime{};
    }
    pub fn run_byte_file(self: *const BeamBapRuntime, file_path: []const u8) !void {
        const file = try std.fs.cwd().openFile(file_path, .{});
        defer file.close();

        const file_size = try file.getEndPos();
        const allocator = std.heap.page_allocator;
        const slice: []u8 = try allocator.alloc(u8, file_size);

        const bytes_read = try file.readAll(slice);

        defer allocator.free(slice);
        try self.run_code(slice, bytes_read);
    }
    fn bytesToU32(self: *const BeamBapRuntime, raw: []const u8) u32 {
        _ = self;
        const b1: u32 = @intCast(raw[0]);
        const b2: u32 = @intCast(raw[1]);
        const b3: u32 = @intCast(raw[2]);
        const b4: u32 = @intCast(raw[3]);

        return (b1 << 24) | (b2 << 16) | (b3 << 8) | b4;
    }

    fn debug_register_and_memory(self: *const BeamBapRuntime, mem: std.AutoHashMap(u32, u32), register: std.ArrayList(u32)) void {
        _ = self;
        std.debug.print("REGISTER: {d}\n", .{register.items});
        std.debug.print("Memory contents:\n", .{});
        var it = mem.iterator();
        while (it.next()) |entry| {
            std.debug.print("Key: {d}, Value: {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        }
        std.debug.print("=====================\n", .{});
    }

    fn run_code(self: *const BeamBapRuntime, bytecodes: []u8, eol: usize) !void {
        // lineo -> op -> args #loading code to mem
        var codes = std.ArrayList(Instruction).init(std.heap.page_allocator);

        var pos: usize = 0;
        while (pos < eol) {
            const opcode: Opcodes = @enumFromInt(bytecodes[pos]);
            pos += 1;

            switch (opcode) {
                Opcodes.PUSH => {
                    const arg_1 = self.bytesToU32(bytecodes[pos..(pos + 4)]);

                    const ins = Instruction{
                        .opcode = Opcodes.PUSH,
                        .args = [_]u32{ arg_1, 0, 0 },
                    };

                    try codes.append(ins);
                    pos += 4;
                },
                Opcodes.ADD => {
                    const ins = Instruction{
                        .opcode = Opcodes.ADD,
                        .args = [_]u32{ 0, 0, 0 },
                    };

                    try codes.append(ins);
                },
                Opcodes.SYSCALL => {
                    const arg_1 = self.bytesToU32(bytecodes[pos..(pos + 4)]);

                    const ins = Instruction{
                        .opcode = Opcodes.SYSCALL,
                        .args = [_]u32{ arg_1, 0, 0 },
                    };
                    pos += 4;
                    try codes.append(ins);
                },
                Opcodes.LOAD => {
                    const arg_1 = self.bytesToU32(bytecodes[pos..(pos + 4)]);

                    const ins = Instruction{
                        .opcode = Opcodes.LOAD,
                        .args = [_]u32{ arg_1, 0, 0 },
                    };

                    try codes.append(ins);
                    pos += 4;
                },
                Opcodes.CMP_LT => {
                    const arg_1 = self.bytesToU32(bytecodes[pos..(pos + 4)]);

                    const ins = Instruction{
                        .opcode = Opcodes.CMP_LT,
                        .args = [_]u32{ arg_1, 0, 0 },
                    };

                    try codes.append(ins);
                    pos += 4;
                },
                Opcodes.NOP => {
                    const ins = Instruction{
                        .opcode = Opcodes.NOP,
                        .args = [_]u32{ 0, 0, 0 },
                    };

                    try codes.append(ins);
                },
                Opcodes.POP => {
                    const arg_1 = self.bytesToU32(bytecodes[pos..(pos + 4)]);
                    const ins = Instruction{
                        .opcode = Opcodes.POP,
                        .args = [_]u32{ arg_1, 0, 0 },
                    };

                    try codes.append(ins);

                    pos += 4;
                },
                Opcodes.STORE => {
                    const arg_1 = self.bytesToU32(bytecodes[pos..(pos + 4)]);
                    pos += 4;
                    const arg_2 = self.bytesToU32(bytecodes[pos..(pos + 4)]);
                    pos += 4;

                    const ins = Instruction{
                        .opcode = Opcodes.STORE,
                        .args = [_]u32{ arg_1, arg_2, 0 },
                    };

                    try codes.append(ins);
                },
            }
        }

        //std.debug.print("{}\n", .{codes});
        try self.run(&codes);
    }

    fn run(self: *const BeamBapRuntime, codes: *std.ArrayList(Instruction)) !void {
        var stack_register = std.ArrayList(u32).init(std.heap.page_allocator);
        defer stack_register.deinit();

        var mem = std.AutoHashMap(u32, u32).init(std.heap.page_allocator);
        defer mem.deinit();

        var pc: usize = 0;

        while (true) {
            if (pc > codes.items.len - 1) {
                break;
            }
            const line_ins = codes.items[pc];
            //std.debug.print("LINEO {}\n", .{line_ins});
            switch (line_ins.opcode) {
                Opcodes.PUSH => {
                    try stack_register.append(line_ins.args[0]);
                },
                Opcodes.ADD => {
                    try stack_register.append(stack_register.pop() + stack_register.pop());
                },
                Opcodes.SYSCALL => {
                    const fun = line_ins.args[0];

                    try self.runtime_syscall(fun, &stack_register);
                },
                Opcodes.LOAD => {
                    const val = try mem.getOrPutValue(line_ins.args[0], 0);
                    try stack_register.append(val.value_ptr.*);
                },
                Opcodes.CMP_LT => {
                    if (stack_register.pop() > stack_register.pop()) {
                        pc = line_ins.args[0];
                        continue;
                    }
                },
                Opcodes.NOP => {},
                Opcodes.POP => {
                    const val = stack_register.pop();
                    try mem.put(line_ins.args[0], val);
                },
                Opcodes.STORE => {
                    const val = line_ins.args[1];
                    const addr = line_ins.args[0];
                    try mem.put(addr, val);
                },
            }
            pc += 1;
            //self.debug_register_and_memory(mem, stack_register);
        }
    }

    fn runtime_syscall(self: *const BeamBapRuntime, func_name: u32, register: *std.ArrayList(u32)) !void {
        _ = self;
        if (func_name == 1919512180) {
            std.debug.print("{}", .{register.pop()});
        }
    }
};
