// src/main.zig - Example usage of the library
const std = @import("std");
const titania = @import("titania");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    const allocator = std.heap.page_allocator;

    try stdout.print("\n=== Prime Factorization Tool ===\n", .{});
    try stdout.print("1. List prime factorization up to N\n", .{});
    try stdout.print("2. Factorize a single number\n", .{});
    try stdout.print("Choose an option (1 or 2): ", .{});

    var choice_buffer: [10]u8 = undefined;
    const choice_input = try stdin.readUntilDelimiterOrEof(&choice_buffer, '\n');
    if (choice_input == null) return;
    
    const choice = std.fmt.parseInt(u32, std.mem.trim(u8, choice_input.?, " \n"), 10) catch {
        try stdout.print("Invalid choice.\n", .{});
        return;
    };

    switch (choice) {
        1 => try listMode(stdout, stdin, allocator),
        2 => try singleMode(stdout, stdin, allocator),
        else => try stdout.print("Invalid choice.\n", .{}),
    }
}

fn listMode(stdout: anytype, stdin: anytype, allocator: std.mem.Allocator) !void {
    try stdout.print("Enter N: ", .{});
    var buffer: [10]u8 = undefined;
    const input = try stdin.readUntilDelimiterOrEof(&buffer, '\n');
    if (input == null) return;
    
    const n = std.fmt.parseInt(usize, std.mem.trim(u8, input.?, " \n"), 10) catch {
        try stdout.print("Invalid number.\n", .{});
        return;
    };

    const spf = try titania.computeSPF(allocator, n);
    defer allocator.free(spf);
    
    try stdout.print("\nPrime factorization up to {}:\n", .{n});
    try titania.printSPFTable(stdout, spf, n);
}

fn singleMode(stdout: anytype, stdin: anytype, allocator: std.mem.Allocator) !void {
    try stdout.print("Enter a number: ", .{});
    var buffer: [20]u8 = undefined;
    const input = try stdin.readUntilDelimiterOrEof(&buffer, '\n');
    if (input == null) return;
    
    const n = std.fmt.parseInt(u64, std.mem.trim(u8, input.?, " \n"), 10) catch {
        try stdout.print("Invalid number.\n", .{});
        return;
    };

    if (n > 10_000_000) {
        try stdout.print("\n{}: ", .{n});
        try titania.factorizeLargeNumber(stdout, n);
        return;
    }

    const spf = try titania.computeSPF(allocator, @as(usize, n));
    defer allocator.free(spf);
    
    const formatted = try titania.formatFactorization(allocator, spf, @as(usize, n));
    defer allocator.free(formatted);
    
    const prime = titania.isPrime(spf, @as(usize, n));
    
    try stdout.print("\n{}: {s}\n", .{n, formatted});
    if (prime) {
        try stdout.print("✓ {} is prime!\n", .{n});
    } else if (n == 1) {
        try stdout.print("Note: 1 is neither prime nor composite.\n", .{});
    } else {
        try stdout.print("✗ {} is composite.\n", .{n});
    }
}