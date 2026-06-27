const std = @import("std");
const File = std.Io.File;

pub fn main(init: std.process.Init) !void {
    _ = try File.stdout().writeStreamingAll(init.io, "Hello, World!\n");
}
