const out = @import("putchar.zig");
const std = @import("std");

const SourceLocation = std.builtin.SourceLocation;

pub fn printf(comptime fmt: []const u8, args: anytype) void {
    comptime var currArg: usize = 0;
    comptime var expecting: bool = false;

    inline for (fmt) |c| {
        if (!expecting) {
            if (c == '{') {
                expecting = true;
            } else if (c != '}') {
                out.putchar(c);
            }
            continue;
        }

        switch (c) {
            '{' => out.putchar('{'),
            's' => {
                printStringArg(args, currArg);
                currArg += 1;
            },
            'd' => {
                printIntArg(args, currArg);
                currArg += 1;
            },
            'x' => {
                printHexArg(args, currArg);
                currArg += 1;
            },
            else => {
                out.putchar('{');
                out.putchar(c);
            },
        }
        expecting = false;
    }

    if (comptime fmt.len != 0 and fmt[fmt.len - 1] == '%') out.putchar('%');
}

fn printStringArg(args: anytype, comptime idx: usize) void {
    inline for (args, 0..) |arg, i| {
        if (comptime i == idx) {
            const s: []const u8 = arg;
            for (s) |b| out.putchar(b);
        }
    }
}

fn printIntArg(args: anytype, comptime idx: usize) void {
    inline for (args, 0..) |arg, i| {
        if (comptime i == idx) {
            const T = @TypeOf(arg);
            const ti = @typeInfo(T);
            const is_signed = switch (ti) {
                .int => |intinfo| intinfo.signedness == .signed,
                .comptime_int => true,
                else => @compileError("%d expects an integer"),
            };

            if (is_signed and arg < 0) out.putchar('-');

            // magnitude as u128
            var n: u128 = if (is_signed)
                @as(u128, @intCast(if (arg < 0) -arg else arg))
            else
                @as(u128, @intCast(arg));

            if (n == 0) {
                out.putchar('0');
                return;
            }

            var buf: [39]u8 = undefined;
            var j: usize = buf.len;
            while (n != 0) {
                j -= 1;
                buf[j] = '0' + @as(u8, @intCast(n % 10));
                n /= 10;
            }
            for (buf[j..]) |b| out.putchar(b);
        }
    }
}

fn printHexArg(args: anytype, comptime idx: usize) void {
    out.putchar('0');
    out.putchar('x');
    inline for (args, 0..) |arg, i| {
        if (comptime i == idx) {
            inline for (0..8) |k| {
                const val = 7 - k;
                const nibble = (arg >> (val * 4)) & 0xf;
                out.putchar("0123456789abcdef"[nibble]);
            }
        }
    }
}

pub fn memcpy(dst: *anyopaque, src: *const anyopaque, n: usize) *anyopaque {
    const d: [*]u8 = @ptrCast(dst);
    const s: [*]const u8 = @ptrCast(src);
    @memcpy(d[0..n], s[0..n]);
    return dst;
}

pub fn memset(dst: *anyopaque, c: u8, n: usize) *anyopaque {
    const d: [*]u8 = @ptrCast(dst);
    @memset(d[0..n], c);
    return dst;
}

pub fn strcpy(dst: []u8, src: []const u8) []u8 {
    var i: usize = 0;
    for (src) |c| {
        dst[i] = c;
        i += 1;
    }
    return dst;
}

pub fn strcmp(str1: []const u8, str2: []const u8) bool {
    for (str1, str2) |s1, s2| {
        if (s1 != s2) return false;
    }
    return true;
}

pub fn panic(comptime msg: []const u8, args: anytype, src: SourceLocation) noreturn {
    printf(msg, args);
    printf("\tin: {s}:{d}\n", .{ src.file, src.line });
    while (true) {}
}
