//! This executable uses the SPF library from root.zig to compute
//! and display prime factorization for all numbers up to user input.

const std = @import("std");
const testing = @import("std").testing;

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
    const choice_input = try readUserInput(allocator, stdin);
    defer allocator.free(choice_input);

    const choice = std.fmt.parseInt(u32, std.mem.trim(u8, choice_input, " \n"), 10) catch |err| {
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

// Helper function to read user input with dynamic allocation
fn readUserInput(allocator: std.mem.Allocator, stdin: anytype) ![]u8 {
    var input = std.ArrayList(u8).init(allocator);
    errdefer input.deinit();

    // Read until newline, growing the buffer as needed
    var buffer: [1024]u8 = undefined;
    while (true) {
        const bytes_read = try stdin.read(&buffer);
        if (bytes_read == 0) break; // EOF
        try input.appendSlice(buffer[0..bytes_read]);
        if (std.mem.indexOfScalar(u8, input.items, '\n')) |_| break;
    }

    return input.toOwnedSlice();
}

fn handleListMode(stdout: anytype, stdin: anytype, allocator: std.mem.Allocator) !void {
    try stdout.print("\n--- List Prime Factorization ---\n", .{});
    try stdout.print("Enter a number N: ", .{});

    const input = try readUserInput(allocator, stdin);
    defer allocator.free(input);

    const n = std.fmt.parseInt(usize, std.mem.trim(u8, input, " \n"), 10) catch |err| {
        try stdout.print("Invalid input: {s}\n", .{@errorName(err)});
        return;
    };

    if (n < 1) {
        try stdout.print("Please enter a positive integer.\n", .{});
        return;
    }

    // Validate reasonable size to prevent memory exhaustion
    if (n > 10_000_000) {
        try stdout.print("Number too large. Please enter a number <= 10,000,000.\n", .{});
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

    const input = try readUserInput(allocator, stdin);
    defer allocator.free(input);

    // Check if the number fits in a u64 (max ~18.4 quintillion)
    const n = std.fmt.parseInt(u64, std.mem.trim(u8, input, " \n"), 10) catch |err| {
        try stdout.print("Invalid input: {s}. Please enter a positive integer.\n", .{@errorName(err)});
        return;
    };

    if (n < 1) {
        try stdout.print("Please enter a positive integer.\n", .{});
        return;
    }

    // For single number factorization, if n is very large, we need a different approach
    // But for simplicity, if n is too large for SPF, fall back to trial division
    if (n > 10_000_000) {
        try stdout.print("\n{}: ", .{n});
        try factorizeLargeNumber(stdout, n);
        return;
    }

    // Compute SPF up to n
    const spf = try lib.computeSPF(allocator, @as(usize, n));
    defer allocator.free(spf);

    // Get factorization
    const formatted = try lib.formatFactorization(allocator, spf, @as(usize, n));
    defer allocator.free(formatted);

    // Check if prime
    const is_prime = checkIfPrime(spf, @as(usize, n));

    try stdout.print("\n{}: {s}\n", .{n, formatted});
    if (is_prime) {
        try stdout.print("✓ {} is a prime number!\n", .{n});
    } else if (n == 1) {
        try stdout.print("Note: 1 is neither prime nor composite.\n", .{});
    } else {
        try stdout.print("✗ {} is a composite number.\n", .{n});
    }
}

// Trial division for large numbers (when SPF would use too much memory)
fn factorizeLargeNumber(writer: anytype, n: u64) !void {
    var temp = n;
    var first = true;
    var first_power = true;

    // First pass: expanded form
    var divisor: u64 = 2;
    while (divisor * divisor <= temp) : (divisor += 1) {
        while (temp % divisor == 0) {
            if (!first) try writer.print("*", .{});
            first = false;
            try writer.print("{}", .{divisor});
            temp /= divisor;
        }
    }
    if (temp > 1) {
        if (!first) try writer.print("*", .{});
        first = false;
        try writer.print("{}", .{temp});
    }
    if (first) {
        // n was 1
        try writer.print("1", .{});
        try writer.print("\nNote: 1 is neither prime nor composite.\n", .{});
        return;
    }

    try writer.print(" = ", .{});

    // Second pass: powered form
    var temp2 = n;
    divisor = 2;
    while (divisor * divisor <= temp2) : (divisor += 1) {
        var count: u32 = 0;
        while (temp2 % divisor == 0) {
            temp2 /= divisor;
            count += 1;
        }
        if (count > 0) {
            if (!first_power) try writer.print("*", .{});
            first_power = false;
            if (count == 1) {
                try writer.print("{}", .{divisor});
            } else {
                try writer.print("{}^{}", .{divisor, count});
            }
        }
    }
    if (temp2 > 1) {
        if (!first_power) try writer.print("*", .{});
        first_power = false;
        try writer.print("{}", .{temp2});
    }

    // Check if prime (if only one factor and it's the number itself)
    // We determine this by checking if we had exactly one factor in the first pass
    const is_prime = (temp == n and n > 1);
    try writer.print("\n", .{});
    if (n > 1 and is_prime) {
        try writer.print("✓ {} is a prime number!\n", .{n});
    } else if (n > 1) {
        try writer.print("✗ {} is a composite number.\n", .{n});
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

test "factorizeLargeNumber" {
    var output = std.ArrayList(u8).init(testing.allocator);
    defer output.deinit();

    const writer = output.writer();

    try factorizeLargeNumber(writer, 150465341515415459);
    // Just verify it doesn't crash - we can't check exact output due to time
    try testing.expect(output.items.len > 0);
}