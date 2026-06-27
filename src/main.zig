//! This executable uses the SPF library from root.zig to compute
//! and display prime factorization for all numbers up to user input.

const std = @import("std");

// Import the library module defined in build.zig
const lib = @import("titania_lib");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    const allocator = std.heap.page_allocator;

    try stdout.print("Enter a number: ", .{});

    // Read user input
    var buffer: [10]u8 = undefined;
    const input = try stdin.readUntilDelimiterOrEof(&buffer, '\n');
    if (input == null) {
        try stdout.print("No input provided.\n", .{});
        return;
    }

    // Parse input
    const n = std.fmt.parseInt(usize, std.mem.trim(u8, input.?, " \n"), 10) catch |err| {
        try stdout.print("Invalid input: {s}\n", .{@errorName(err)});
        return;
    };

    if (n < 1) {
        try stdout.print("Please enter a positive integer.\n", .{});
        return;
    }

    // Compute SPF using the library function
    try stdout.print("Computing SPF for {} numbers...\n", .{n});
    const spf = try lib.computeSPF(allocator, n);
    defer allocator.free(spf);

    // Print results using the library function
    try stdout.print("\nPrime factorization up to {}:\n", .{n});
    try lib.printSPFTable(stdout, spf, n);
}