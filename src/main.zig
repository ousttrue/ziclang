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
    const cxstr  = libclang.clang_getCursorKindSpelling(libclang.clang_getCursorKind(cursor));
    defer libclang.clang_disposeString(cxstr);
    const str = libclang.clang_getCString(cxstr);
    // @compileLog(@TypeOf(str));
    std.debug.print("{s}\n", .{str});
    return libclang.CXChildVisit_Recurse;
}

pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{});

    const index = libclang.clang_createIndex(0, 0);
    defer libclang.clang_disposeIndex(index);

    const source_name = "tmp.cpp";
    const command_line = [_][]const u8{};
    const flags = 0;
    var unsaved_files = [_]libclang.CXUnsavedFile{libclang.CXUnsavedFile{
        .Filename = source_name,
        .Contents = SOURCE,
        .Length = SOURCE.len,
    }};
    var tu: libclang.CXTranslationUnit = undefined;
    const result = libclang.clang_parseTranslationUnit2(index, source_name,
    //command_line,
    null, command_line.len,
    // unsaved_files,
    &unsaved_files[0], unsaved_files.len, flags, &tu);
    assert(result == libclang.CXError_Success);
    defer libclang.clang_disposeTranslationUnit(tu);

    // traverse
    _ = libclang.clang_visitChildren(libclang.clang_getTranslationUnitCursor(tu), callback, null);
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
