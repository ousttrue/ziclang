const std = @import("std");
const assert = std.debug.assert;

const libclang = @cImport({
    @cInclude("clang-c/Index.h");
});

const SOURCE =
    \\int main()
    \\{        
    \\  return 0;
    \\}
;

fn callback(cursor: libclang.CXCursor, _: libclang.CXCursor, _: libclang.CXClientData) callconv(.C) libclang.CXChildVisitResult {
    const cxstr = libclang.clang_getCursorKindSpelling(libclang.clang_getCursorKind(cursor));
    defer libclang.clang_disposeString(cxstr);
    const str = libclang.clang_getCString(cxstr);
    // @compileLog(@TypeOf(str));
    std.debug.print("{s}\n", .{str});
    return libclang.CXChildVisit_Recurse;
}

const DEFAULT_ARGS = [_][]const u8{
    "-x",
    "c++",
    "-std=c++17",
    "-target",
    "x86_64-windows-msvc",
    "-fdeclspec",
    "-fms-compatibility-version=18",
    "-fms-compatibility",
    "-DNOMINMAX",
};

pub fn main() anyerror!void {
    // args
    const test_allocator = std.testing.allocator;
    var args = try std.process.argsWithAllocator(test_allocator);
    defer args.deinit();

    var command_line = std.ArrayList(*const u8).init(test_allocator);
    for (DEFAULT_ARGS) |arg| {
        try command_line.append(&arg[0]);
    }

    var i: i32 = 0;
    var source_name: []const u8 = "";
    while (true) {
        if (args.next()) |arg| {
            if (i == 1) {
                std.debug.print("entry: {s}\n", .{arg});
                source_name = arg;
            } else if (i > 1) {
                std.debug.print("command_line: {s}\n", .{arg});
                try command_line.append(&arg[0]);
            }
            i += 1;
        } else {
            break;
        }
    }

    // get_tu
    const index = libclang.clang_createIndex(0, 0);
    defer libclang.clang_disposeIndex(index);

    const flags = libclang.CXTranslationUnit_DetailedPreprocessingRecord | libclang.CXTranslationUnit_SkipFunctionBodies;
    // var unsaved_files = [_]libclang.CXUnsavedFile{libclang.CXUnsavedFile{
    //     .Filename = source_name,
    //     .Contents = SOURCE,
    //     .Length = SOURCE.len,
    // }};
    var tu: libclang.CXTranslationUnit = undefined;
    const result = libclang.clang_parseTranslationUnit2(index, &source_name[0],
    //command_line,
    &command_line.items[0], @intCast(i32, command_line.items.len),
    // unsaved_files,
    null, 0, flags,
    //
    &tu);
    switch (result) {
        0 => {}, // SUCCESS
        1 => @panic("failer"),
        2 => @panic("crash"),
        3 => @panic("invalid arguments"),
        4 => @panic("AST read error"),
        else => @panic("unknown"),
    }
    defer libclang.clang_disposeTranslationUnit(tu);

    // traverse
    _ = libclang.clang_visitChildren(libclang.clang_getTranslationUnitCursor(tu), callback, null);
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
