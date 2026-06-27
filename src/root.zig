//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

// Your existing add function
pub export fn add(a: i32, b: i32) i32 {
    return a + b;
}

// SPF sieve function - returns the smallest prime factor for each number up to n
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

// Format a single number's factorization as a string
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

    // First pass: write expanded form (2*2*3*3*3)
    while (temp > 1) {
        const p = spf[temp];
        var count: u32 = 0;
        while (temp % p == 0) {
            temp /= p;
            count += 1;
        }

        // Add each prime factor individually for expanded form
        var i: u32 = 0;
        while (i < count) : (i += 1) {
            if (!first) try result.append('*');
            first = false;
            try result.writer().print("{}", .{p});
        }
    }

    // Add " = " separator
    try result.appendSlice(" = ");

    // Second pass: write powered form (2^2*3^3)
    temp = num; // Reset temp
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
            try result.writer().print("{}^{}", .{p, count});
        }
    }

    return result.toOwnedSlice();
}

// Print full SPF table with formatted factorization for all numbers
pub fn printSPFTable(writer: anytype, spf: []u32, n: usize) !void {
    var allocator = std.heap.page_allocator; // Using global allocator for simplicity

    for (1..n + 1) |num| {
        const formatted = try formatFactorization(allocator, spf, num);
        defer allocator.free(formatted);
        try writer.print("{}: {s}\n", .{num, formatted});
    }
}

test "SPF for 10" {
    const allocator = testing.allocator;
    const spf = try computeSPF(allocator, 10);
    defer allocator.free(spf);

    // Expected SPF values
    const expected = [_]u32{0, 0, 2, 3, 2, 5, 2, 7, 2, 3, 2};
    for (0..spf.len) |i| {
        try testing.expectEqual(expected[i], spf[i]);
    }
}

test "format factorization expanded" {
    const allocator = testing.allocator;
    const spf = try computeSPF(allocator, 108);
    defer allocator.free(spf);

    const result = try formatFactorization(allocator, spf, 108);
    defer allocator.free(result);
    try testing.expectEqualStrings("2*2*3*3*3 = 2^2*3^3", result);
}

test "format factorization prime number" {
    const allocator = testing.allocator;
    const spf = try computeSPF(allocator, 7);
    defer allocator.free(spf);

    const result = try formatFactorization(allocator, spf, 7);
    defer allocator.free(result);
    try testing.expectEqualStrings("7 = 7", result);
}

test "format factorization 1" {
    const allocator = testing.allocator;
    const spf = try computeSPF(allocator, 1);
    defer allocator.free(spf);

    const result = try formatFactorization(allocator, spf, 1);
    defer allocator.free(result);
    try testing.expectEqualStrings("1", result);
}