const out = @import("common.zig");

extern var __stack_top: u8;

pub export fn _start() callconv(.naked) noreturn {
    const top: usize = @intFromPtr(&__stack_top);
    asm volatile (
        \\ mv sp, %[stack_top]
        \\ j kernelMain
        :
        : [stack_top] "r" (top),
    );
}

pub export fn kernelMain() callconv(.c) noreturn {
    out.printf("hello {s}\n{d}\n{x}\n", .{ "world", 42, 0x1234abcd });
    out.panic("testing panic", @src());
    while (true) asm volatile ("wfi");
}
