//! This executable uses the SPF library from root.zig to compute
//! and display prime factorization for all numbers up to user input.

const std = @import("std");
const testing = @import("std").testing; // Add this import for tests

// Import the library module defined in build.zig
const lib = @import("titania_lib");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    const allocator = std.heap.page_allocator;

    try stdout.print("\n=== Prime Factorization Tool ===\n", .{});
    try stdout.print("1. List prime factorization up to N\n", .{});
    try stdout.print("2. Factorize a single number\n", .{});
    try stdout.print("Choose an option (1 or 2): ", .{});

    // Read user choice
    var choice_buffer: [10]u8 = undefined;
    const choice_input = try stdin.readUntilDelimiterOrEof(&choice_buffer, '\n');
    if (choice_input == null) {
        try stdout.print("No input provided.\n", .{});
        return;
    }

    const choice = std.fmt.parseInt(u32, std.mem.trim(u8, choice_input.?, " \n"), 10) catch |err| {
        try stdout.print("Invalid choice: {s}\n", .{@errorName(err)});
        return;
    };

    switch (choice) {
        1 => try handleListMode(stdout, stdin, allocator),
        2 => try handleSingleMode(stdout, stdin, allocator),
        else => {
            try stdout.print("Invalid choice. Please enter 1 or 2.\n", .{});
            return;
        },
    }
}

fn handleListMode(stdout: anytype, stdin: anytype, allocator: std.mem.Allocator) !void {
    try stdout.print("\n--- List Prime Factorization ---\n", .{});
    try stdout.print("Enter a number N: ", .{});

    var buffer: [10]u8 = undefined;
    const input = try stdin.readUntilDelimiterOrEof(&buffer, '\n');
    if (input == null) {
        try stdout.print("No input provided.\n", .{});
        return;
    }

    const n = std.fmt.parseInt(usize, std.mem.trim(u8, input.?, " \n"), 10) catch |err| {
        try stdout.print("Invalid input: {s}\n", .{@errorName(err)});
        return;
    };

    if (n < 1) {
        try stdout.print("Please enter a positive integer.\n", .{});
        return;
    }

    try stdout.print("\nComputing SPF for {} numbers...\n", .{n});
    const spf = try lib.computeSPF(allocator, n);
    defer allocator.free(spf);

    try stdout.print("\nPrime factorization up to {}:\n", .{n});
    try lib.printSPFTable(stdout, spf, n);
}

fn handleSingleMode(stdout: anytype, stdin: anytype, allocator: std.mem.Allocator) !void {
    try stdout.print("\n--- Factorize Single Number ---\n", .{});
    try stdout.print("Enter a number: ", .{});

    var buffer: [10]u8 = undefined;
    const input = try stdin.readUntilDelimiterOrEof(&buffer, '\n');
    if (input == null) {
        try stdout.print("No input provided.\n", .{});
        return;
    }

    const n = std.fmt.parseInt(usize, std.mem.trim(u8, input.?, " \n"), 10) catch |err| {
        try stdout.print("Invalid input: {s}\n", .{@errorName(err)});
        return;
    };

    if (n < 1) {
        try stdout.print("Please enter a positive integer.\n", .{});
        return;
    }

    // Compute SPF up to n
    const spf = try lib.computeSPF(allocator, n);
    defer allocator.free(spf);

    // Get factorization
    const formatted = try lib.formatFactorization(allocator, spf, n);
    defer allocator.free(formatted);

    // Check if prime
    const is_prime = checkIfPrime(spf, n);

    try stdout.print("\n{}: {s}\n", .{n, formatted});
    if (is_prime) {
        try stdout.print("✓ {} is a prime number!\n", .{n});
    } else if (n == 1) {
        try stdout.print("Note: 1 is neither prime nor composite.\n", .{});
    } else {
        try stdout.print("✗ {} is a composite number.\n", .{n});
    }
}

fn checkIfPrime(spf: []u32, n: usize) bool {
    if (n < 2) return false;
    // A number is prime if its smallest prime factor is itself
    return spf[n] == n;
}

// Tests
test "checkIfPrime" {
    const allocator = testing.allocator;
    const spf = try lib.computeSPF(allocator, 20);
    defer allocator.free(spf);

    try testing.expect(checkIfPrime(spf, 2));
    try testing.expect(checkIfPrime(spf, 3));
    try testing.expect(checkIfPrime(spf, 5));
    try testing.expect(checkIfPrime(spf, 7));
    try testing.expect(checkIfPrime(spf, 11));
    try testing.expect(checkIfPrime(spf, 13));
    try testing.expect(checkIfPrime(spf, 17));
    try testing.expect(checkIfPrime(spf, 19));

    try testing.expect(!checkIfPrime(spf, 1));
    try testing.expect(!checkIfPrime(spf, 4));
    try testing.expect(!checkIfPrime(spf, 6));
    try testing.expect(!checkIfPrime(spf, 8));
    try testing.expect(!checkIfPrime(spf, 9));
    try testing.expect(!checkIfPrime(spf, 10));
    try testing.expect(!checkIfPrime(spf, 12));
    try testing.expect(!checkIfPrime(spf, 14));
    try testing.expect(!checkIfPrime(spf, 15));
    try testing.expect(!checkIfPrime(spf, 16));
    try testing.expect(!checkIfPrime(spf, 18));
    try testing.expect(!checkIfPrime(spf, 20));
}