const out = @import("putchar.zig");

const uint_8 = u8;
const uint_32 = u32;
const size_t = usize;

extern var __bss: u8;
extern var __bss_end: u8;
extern var __stack_top: u8;

pub export fn _start() callconv(.naked) noreturn {
    const top: usize = @intFromPtr(&__stack_top);
    asm volatile (
        \\ mv sp, %[stack_top]
        \\ j kernel_main
        :
        : [stack_top] "r" (top),
    );
}

pub export fn kernel_main() callconv(.c) noreturn {
    const msg = "\n\nHello World!\n";
    for (msg) |c| out.putchar(c);

    while (true) asm volatile ("wfi");
}

pub export fn memset(buf: *anyopaque, c: u8, n: usize) *anyopaque {
    var p: [*]u8 = @ptrCast(buf);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        p[i] = c;
    }
    return buf;
}
