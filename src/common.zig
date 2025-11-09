const out = @import("putchar.zig");

pub fn printf(comptime fmt: []const u8, args: anytype) void {
    comptime var ai: usize = 0;
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
                printStringArg(args, ai);
                ai += 1;
            },
            'd' => {
                printIntArg(args, ai);
                ai += 1;
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
