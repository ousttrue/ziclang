const std = @import("std");

const libclang = @cImport({
    @cInclude("clang-c/Index.h");
});

pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{});

    const index = libclang.clang_createIndex(0, 0);
    defer libclang.clang_disposeIndex(index);

    const source_name = "tmp.cpp";
    const command_line = [_] [] const u8{};
    const flags = 0;
    const unsaved_files = [_]libclang.CXUnsavedFile{};
    const tu = libclang.clang_parseTranslationUnit(index, source_name, 
        //command_line, 
        null,
        command_line.len, 
        // unsaved_files, 
        null,
        unsaved_files.len, flags);
    defer libclang.clang_disposeTranslationUnit(tu);
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
