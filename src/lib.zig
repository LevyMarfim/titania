// src/lib.zig
const std = @import("std");

// Re-export all public functions from spf.zig
pub const computeSPF = @import("spf.zig").computeSPF;
pub const formatFactorization = @import("spf.zig").formatFactorization;
pub const printSPFTable = @import("spf.zig").printSPFTable;
pub const isPrime = @import("spf.zig").isPrime;
pub const factorizeLargeNumber = @import("spf.zig").factorizeLargeNumber;

// Also expose the SPF module directly
pub const spf = @import("spf.zig");

// Library version info
pub const version = "0.1.0";
