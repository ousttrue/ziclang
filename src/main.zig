const std = @import("std");

const clang = @cImport({
    @cInclude("clang-c/Index.h");
});

pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{});

    const index = clang.clang_createIndex(0, 0);
    defer clang.clang_disposeIndex(index);
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
