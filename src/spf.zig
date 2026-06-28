// src/spf.zig
const std = @import("std");

/// Computes the Smallest Prime Factor (SPF) for all numbers up to n.
/// Returns an array of u32 where spf[i] is the smallest prime factor of i.
/// Memory must be freed by the caller.
pub fn computeSPF(allocator: std.mem.Allocator, n: usize) ![]u32 {
    var spf = try allocator.alloc(u32, n + 1);
    @memset(spf, 0);

    // Sieve to compute Smallest Prime Factor for each number
    for (2..n + 1) |i| {
        if (spf[i] == 0) { // i is prime
            var j = i;
            while (j <= n) : (j += i) {
                if (spf[j] == 0) {
                    spf[j] = @intCast(i);
                }
            }
        }
    }
    return spf;
}

/// Formats a single number's prime factorization as a string.
/// Returns expanded form: "2*2*3" and powered form: "2^2*3"
pub fn formatFactorization(allocator: std.mem.Allocator, spf: []u32, num: usize) ![]u8 {
    var result = std.ArrayList(u8).init(allocator);
    errdefer result.deinit();

    if (num == 1) {
        try result.appendSlice("1");
        return result.toOwnedSlice();
    }

    var temp = num;
    var first = true;
    var first_power = true;

    // First pass: expanded form
    while (temp > 1) {
        const p = spf[temp];
        var count: u32 = 0;
        while (temp % p == 0) {
            temp /= p;
            count += 1;
        }

        var i: u32 = 0;
        while (i < count) : (i += 1) {
            if (!first) try result.append('*');
            first = false;
            try result.writer().print("{}", .{p});
        }
    }

    try result.appendSlice(" = ");

    // Second pass: powered form
    temp = num;
    while (temp > 1) {
        const p = spf[temp];
        var count: u32 = 0;
        while (temp % p == 0) {
            temp /= p;
            count += 1;
        }

        if (!first_power) try result.append('*');
        first_power = false;

        if (count == 1) {
            try result.writer().print("{}", .{p});
        } else {
            try result.writer().print("{}^{}", .{ p, count });
        }
    }

    return result.toOwnedSlice();
}

/// Prints the SPF table with formatted factorization for all numbers 1..n
pub fn printSPFTable(writer: anytype, spf: []u32, n: usize) !void {
    const allocator = std.heap.page_allocator;

    for (1..n + 1) |num| {
        const formatted = try formatFactorization(allocator, spf, num);
        defer allocator.free(formatted);
        try writer.print("{}: {s}\n", .{ num, formatted });
    }
}

/// Checks if a number is prime using its SPF
pub fn isPrime(spf: []u32, n: usize) bool {
    if (n < 2) return false;
    return spf[n] == n;
}

/// Trial division for large numbers (when SPF would use too much memory)
pub fn factorizeLargeNumber(writer: anytype, n: u64) !void {
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
                try writer.print("{}^{}", .{ divisor, count });
            }
        }
    }
    if (temp2 > 1) {
        if (!first_power) try writer.print("*", .{});
        first_power = false;
        try writer.print("{}", .{temp2});
    }

    const is_prime = (temp == n and n > 1);
    try writer.print("\n", .{});
    if (n > 1 and is_prime) {
        try writer.print("✓ {} is a prime number!\n", .{n});
    } else if (n > 1) {
        try writer.print("✗ {} is a composite number.\n", .{n});
    }
}
