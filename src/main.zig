const std = @import("std");
const bb = @import("runtime.zig");
const Opcodes = bb.Opcodes;

pub fn mem_name_to_uint32(word: []const u8) u32 {
    var combined: u32 = 0;
    for (word) |char| {
        combined = (combined << 8) | char;
    }
    return combined;
}

const ByteCodeBuilder = struct {
    sequence: *std.ArrayList(u8), // stored per byte
    module_name: []const u8,
    fn add_instruction(self: *ByteCodeBuilder, opcode: Opcodes, args: []const u32) !void {
        try self.sequence.append(@intFromEnum(opcode));

        for (args) |arg| {
            var a1: u8 = @intCast((arg >> 24) & 255);
            try self.sequence.append(a1);
            a1 = @intCast((arg >> 16) & 255);
            try self.sequence.append(a1);
            a1 = @intCast((arg >> 8) & 255);
            try self.sequence.append(a1);
            a1 = @intCast((arg) & 255);
            try self.sequence.append(a1);
        }
    }
    fn write_bytecode_file(self: *ByteCodeBuilder) !void {
        const file_name = try std.fmt.allocPrint(
            self.sequence.allocator,
            "{s}.bin",
            .{self.module_name},
        );
        const file = try std.fs.cwd().createFile(file_name, .{ .read = true });
        defer file.close();

        const writer = file.writer();

        for (self.sequence.items) |code| {
            try writer.writeByte(code);
        }
    }
};

test "create_byte_code" {
    const allocator = std.heap.page_allocator;
    var seq = std.ArrayList(u8).init(allocator);
    defer seq.deinit();
    var bytecode_builder = ByteCodeBuilder{ .sequence = &seq, .module_name = "main" };

    // 0   STORE i #0
    // 1   STORE n #10
    // 2   STORE r #0
    // 3   LOAD r
    // 4   PUSH #5
    // 5   ADD
    // 6   POP r
    // 7   LOAD i
    // 8   PUSH #1
    // 9   ADD
    // 10  POP i
    // 11  LOAD i
    // 12  LOAD n
    // 13  CMP_LT 3
    // 14  LOAD r
    // 14  SYSCALL print

    try bytecode_builder.add_instruction(Opcodes.STORE, &[_]u32{ mem_name_to_uint32("i"), 0 });
    try bytecode_builder.add_instruction(Opcodes.STORE, &[_]u32{ mem_name_to_uint32("n"), 10 });
    try bytecode_builder.add_instruction(Opcodes.STORE, &[_]u32{ mem_name_to_uint32("r"), 0 });
    try bytecode_builder.add_instruction(Opcodes.LOAD, &[_]u32{mem_name_to_uint32("r")});
    try bytecode_builder.add_instruction(Opcodes.PUSH, &[_]u32{5});
    try bytecode_builder.add_instruction(Opcodes.ADD, &[_]u32{});
    try bytecode_builder.add_instruction(Opcodes.POP, &[_]u32{mem_name_to_uint32("r")});
    try bytecode_builder.add_instruction(Opcodes.LOAD, &[_]u32{mem_name_to_uint32("i")});
    try bytecode_builder.add_instruction(Opcodes.PUSH, &[_]u32{1});
    try bytecode_builder.add_instruction(Opcodes.ADD, &[_]u32{});
    try bytecode_builder.add_instruction(Opcodes.POP, &[_]u32{mem_name_to_uint32("i")});
    try bytecode_builder.add_instruction(Opcodes.LOAD, &[_]u32{mem_name_to_uint32("i")});
    try bytecode_builder.add_instruction(Opcodes.LOAD, &[_]u32{mem_name_to_uint32("n")});
    try bytecode_builder.add_instruction(Opcodes.CMP_LT, &[_]u32{3});
    try bytecode_builder.add_instruction(Opcodes.LOAD, &[_]u32{mem_name_to_uint32("r")});
    try bytecode_builder.add_instruction(Opcodes.SYSCALL, &[_]u32{mem_name_to_uint32("print")});

    try bytecode_builder.write_bytecode_file();
}

test "create_run_code" {
    const allocator = std.heap.page_allocator;
    var seq = std.ArrayList(u8).init(allocator);
    defer seq.deinit();
    var bytecode_builder = ByteCodeBuilder{ .sequence = &seq, .module_name = "main" };
    try bytecode_builder.add_instruction(Opcodes.STORE, &[_]u32{ mem_name_to_uint32("i"), 0 });
    try bytecode_builder.add_instruction(Opcodes.STORE, &[_]u32{ mem_name_to_uint32("r"), 0 });
    try bytecode_builder.add_instruction(Opcodes.STORE, &[_]u32{ mem_name_to_uint32("n"), 15000000 });

    try bytecode_builder.add_instruction(Opcodes.LOAD, &[_]u32{mem_name_to_uint32("r")});
    try bytecode_builder.add_instruction(Opcodes.PUSH, &[_]u32{5});
    try bytecode_builder.add_instruction(Opcodes.ADD, &[_]u32{});
    try bytecode_builder.add_instruction(Opcodes.POP, &[_]u32{mem_name_to_uint32("r")});
    try bytecode_builder.add_instruction(Opcodes.LOAD, &[_]u32{mem_name_to_uint32("i")});
    try bytecode_builder.add_instruction(Opcodes.PUSH, &[_]u32{1});
    try bytecode_builder.add_instruction(Opcodes.ADD, &[_]u32{});
    try bytecode_builder.add_instruction(Opcodes.POP, &[_]u32{mem_name_to_uint32("i")});

    // print step
    //try bytecode_builder.add_instruction(Opcodes.LOAD, &[_]u32{mem_name_to_uint32("r")});
    //try bytecode_builder.add_instruction(Opcodes.SYSCALL, &[_]u32{mem_name_to_uint32("print")});

    try bytecode_builder.add_instruction(Opcodes.LOAD, &[_]u32{mem_name_to_uint32("i")});
    try bytecode_builder.add_instruction(Opcodes.LOAD, &[_]u32{mem_name_to_uint32("n")});
    try bytecode_builder.add_instruction(Opcodes.CMP_LT, &[_]u32{3});
    try bytecode_builder.add_instruction(Opcodes.LOAD, &[_]u32{mem_name_to_uint32("r")});
    try bytecode_builder.add_instruction(Opcodes.SYSCALL, &[_]u32{mem_name_to_uint32("print")});

    try bytecode_builder.write_bytecode_file();

    // run code

    const runtime = bb.BeamBapRuntime.init();

    try runtime.run_byte_file("/Users/alfiankan/beambap/main.bin");
}
