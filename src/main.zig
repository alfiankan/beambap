const std = @import("std");

pub fn mem_name_to_uint64(word: []const u8) u8 {
    var combined: u8 = 0;
    for (word) |char| {
        combined = (combined << 4) | char;
    }
    return combined;
}

test "create_byte_code" {

    // 0   STORE i #0
    // 1   STORE n #10
    // 2   STORE r #0
    // 3   PUSH r
    // 4   PUSH #5
    // 5   ADD
    // 6   POP r
    // 7   PUSH i
    // 8   PUSH #1
    // 9   ADD
    // 10  POP i
    // 11  PUSH i
    // 12  PUSH n
    // 13  CMP_LT 3
    // 14  PUSH r
    // 14  SYSCALL print

    const Opcodes = enum(u8) {
        NOP = 0,
        STORE = 1,
        PUSH = 2,
        ADD = 3,
        POP = 4,
        CMP_LT = 5,
        SYSCALL = 6,
    };

    const codes = [_]u8{
        @intFromEnum(Opcodes.NOP),
        @intFromEnum(Opcodes.STORE),
        mem_name_to_uint64("i"),
        0,
        @intFromEnum(Opcodes.STORE),
        mem_name_to_uint64("n"),
        10,
        @intFromEnum(Opcodes.STORE),
        mem_name_to_uint64("r"),
        0,
        @intFromEnum(Opcodes.PUSH),
        mem_name_to_uint64("r"),
        @intFromEnum(Opcodes.PUSH),
        5,
        @intFromEnum(Opcodes.ADD),
        @intFromEnum(Opcodes.POP),
        mem_name_to_uint64("r"),
        @intFromEnum(Opcodes.PUSH),
        mem_name_to_uint64("i"),
        @intFromEnum(Opcodes.PUSH),
        1,
        @intFromEnum(Opcodes.ADD),
        @intFromEnum(Opcodes.POP),
        mem_name_to_uint64("i"),
        @intFromEnum(Opcodes.PUSH),
        mem_name_to_uint64("i"),
        @intFromEnum(Opcodes.PUSH),
        mem_name_to_uint64("n"),
        @intFromEnum(Opcodes.CMP_LT),
        3,
        @intFromEnum(Opcodes.PUSH),
        mem_name_to_uint64("r"),
        @intFromEnum(Opcodes.SYSCALL),
    };

    const file = try std.fs.cwd().createFile("add.bin", .{ .read = true });
    defer file.close();

    const writer = file.writer();

    for (codes) |code| {
        try writer.writeByte(code);
    }
}
