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

        std.debug.print("{d} \n", .{slice[0]});
        std.debug.print("LENGTH: {d} \n", .{bytes_read});

        defer allocator.free(slice);
        try self.run(slice, bytes_read);
    }
    fn bytesToU32(self: *const BeamBapRuntime, raw: []const u8) u32 {
        _ = self;
        const b1: u32 = @intCast(raw[0]);
        const b2: u32 = @intCast(raw[1]);
        const b3: u32 = @intCast(raw[2]);
        const b4: u32 = @intCast(raw[3]);

        return (b1 << 24) | (b2 << 16) | (b3 << 8) | b4;
    }

    fn run(self: *const BeamBapRuntime, bytecodes: []u8, eol: usize) !void {
        var pos: usize = 0;

        var stack_register = std.ArrayList(u32).init(std.heap.page_allocator);
        defer stack_register.deinit();

        var mem = std.AutoHashMap(u32, u32).init(std.heap.page_allocator);
        defer mem.deinit();

        while (true) {
            if (pos > eol - 1) {
                break;
            }
            const opcode: Opcodes = @enumFromInt(bytecodes[pos]);
            std.debug.print("BUFFER OPCODE: {d} \n", .{@intFromEnum(opcode)});

            pos += 1;
            switch (opcode) {
                Opcodes.PUSH => {

                    // get 32 bit 4 bytecode segemnts
                    const arg_1 = self.bytesToU32(bytecodes[pos..(pos + 4)]);
                    std.debug.print("ddfdfd {d}\n", .{arg_1});

                    try stack_register.append(arg_1);
                    std.debug.print("REGISTER: {d}\n", .{stack_register.items});

                    pos += 4;
                },
                Opcodes.ADD => {
                    std.debug.print("ADDD", .{});

                    const adder_result = stack_register.pop() + stack_register.pop();
                    try stack_register.append(adder_result);
                    std.debug.print("REGISTER: {d}\n", .{stack_register.items});
                },
                Opcodes.SYSCALL => {},
                Opcodes.LOAD => {},
                Opcodes.CMP_LT => {},
                Opcodes.NOP => {
                    std.debug.print("NOP\n", .{});
                },
                Opcodes.POP => {
                    const arg_1 = self.bytesToU32(bytecodes[pos..(pos + 4)]);
                    try mem.put(arg_1, stack_register.pop());
                    std.debug.print("REGISTER: {d}\n", .{stack_register.items});

                    pos += 4;
                },
                Opcodes.STORE => {},
            }
        }

        std.debug.print("HashMap contents:\n", .{});
        var it = mem.iterator();
        while (it.next()) |entry| {
            std.debug.print("Key: {d}, Value: {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        }
    }
};
