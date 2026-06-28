// tests/spf_tests.zig
const std = @import("std");
const testing = std.testing;
const titania = @import("titania");

test "SPF for 10" {
    const allocator = testing.allocator;
    const spf = try titania.computeSPF(allocator, 10);
    defer allocator.free(spf);

    const expected = [_]u32{ 0, 0, 2, 3, 2, 5, 2, 7, 2, 3, 2 };
    for (0..spf.len) |i| {
        try testing.expectEqual(expected[i], spf[i]);
    }
}

test "format factorization" {
    const allocator = testing.allocator;
    const spf = try titania.computeSPF(allocator, 108);
    defer allocator.free(spf);

    const result = try titania.formatFactorization(allocator, spf, 108);
    defer allocator.free(result);
    try testing.expectEqualStrings("2*2*3*3*3 = 2^2*3^3", result);
}

test "isPrime" {
    const allocator = testing.allocator;
    const spf = try titania.computeSPF(allocator, 20);
    defer allocator.free(spf);

    try testing.expect(titania.isPrime(spf, 2));
    try testing.expect(titania.isPrime(spf, 17));
    try testing.expect(!titania.isPrime(spf, 1));
    try testing.expect(!titania.isPrime(spf, 4));
}
