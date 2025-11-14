const out = @import("common.zig");
const std = @import("std");

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

pub export fn kernelMain() linksection(".text.boot") noreturn {
    out.log("starting kernel...", .{});

    const trap_vector_addr: u32 = @intFromPtr(&trap_vector);
    out.log("trap vector address: {x}", .{trap_vector_addr});
    writeCsr("stvec", trap_vector_addr);
    asm volatile ("unimp");

    out.log("continuing execution...", .{});
    while (true) asm volatile ("wfi");
}

// Called by `trap_vector.S` - assembly stub.
// It's a workaround for lack of align(X) on functions in Zig. Alignment is
// needed for setting `stvec` properly - CPU aligns the invalid address on it's own.
//
// This assembly stub calls `kernelEntry`.
extern fn trap_vector() callconv(.naked) void;

pub export fn kernelEntry() callconv(.naked) void {
    asm volatile (
        \\ csrw sscratch, sp
        \\ addi sp, sp, -4 * 31
        \\ sw ra,  4 * 0(sp)
        \\ sw gp,  4 * 1(sp)
        \\ sw tp,  4 * 2(sp)
        \\ sw t0,  4 * 3(sp)
        \\ sw t1,  4 * 4(sp)
        \\ sw t2,  4 * 5(sp)
        \\ sw t3,  4 * 6(sp)
        \\ sw t4,  4 * 7(sp)
        \\ sw t5,  4 * 8(sp)
        \\ sw t6,  4 * 9(sp)
        \\ sw a0,  4 * 10(sp)
        \\ sw a1,  4 * 11(sp)
        \\ sw a2,  4 * 12(sp)
        \\ sw a3,  4 * 13(sp)
        \\ sw a4,  4 * 14(sp)
        \\ sw a5,  4 * 15(sp)
        \\ sw a6,  4 * 16(sp)
        \\ sw a7,  4 * 17(sp)
        \\ sw s0,  4 * 18(sp)
        \\ sw s1,  4 * 19(sp)
        \\ sw s2,  4 * 20(sp)
        \\ sw s3,  4 * 21(sp)
        \\ sw s4,  4 * 22(sp)
        \\ sw s5,  4 * 23(sp)
        \\ sw s6,  4 * 24(sp)
        \\ sw s7,  4 * 25(sp)
        \\ sw s8,  4 * 26(sp)
        \\ sw s9,  4 * 27(sp)
        \\ sw s10, 4 * 28(sp)
        \\ sw s11, 4 * 29(sp)
        \\ csrr a0, sscratch
        \\ sw a0, 4 * 30(sp)
        \\ mv a0, sp
        \\ call handleTrap
        \\ lw ra,  4 * 0(sp)
        \\ lw gp,  4 * 1(sp)
        \\ lw tp,  4 * 2(sp)
        \\ lw t0,  4 * 3(sp)
        \\ lw t1,  4 * 4(sp)
        \\ lw t2,  4 * 5(sp)
        \\ lw t3,  4 * 6(sp)
        \\ lw t4,  4 * 7(sp)
        \\ lw t5,  4 * 8(sp)
        \\ lw t6,  4 * 9(sp)
        \\ lw a0,  4 * 10(sp)
        \\ lw a1,  4 * 11(sp)
        \\ lw a2,  4 * 12(sp)
        \\ lw a3,  4 * 13(sp)
        \\ lw a4,  4 * 14(sp)
        \\ lw a5,  4 * 15(sp)
        \\ lw a6,  4 * 16(sp)
        \\ lw a7,  4 * 17(sp)
        \\ lw s0,  4 * 18(sp)
        \\ lw s1,  4 * 19(sp)
        \\ lw s2,  4 * 20(sp)
        \\ lw s3,  4 * 21(sp)
        \\ lw s4,  4 * 22(sp)
        \\ lw s5,  4 * 23(sp)
        \\ lw s6,  4 * 24(sp)
        \\ lw s7,  4 * 25(sp)
        \\ lw s8,  4 * 26(sp)
        \\ lw s9,  4 * 27(sp)
        \\ lw s10, 4 * 28(sp)
        \\ lw s11, 4 * 29(sp)
        \\ lw sp,  4 * 30(sp)
        \\ sret
    );
}

pub export fn handleTrap(_: *TrapFrame) callconv(.c) noreturn {
    const scause: u32 = readCsr("scause");
    const stval: u32 = readCsr("stval");
    const user_pc: u32 = readCsr("sepc");
    out.panic("unexpected trap scause={x}, stval={x}, sepc={x}", .{
        scause,
        stval,
        user_pc,
    }, @src());
}

const TrapFrame = packed struct {
    ra: u32,
    gp: u32,
    tp: u32,
    t0: u32,
    t1: u32,
    t2: u32,
    t3: u32,
    t4: u32,
    t5: u32,
    t6: u32,
    a0: u32,
    a1: u32,
    a2: u32,
    a3: u32,
    a4: u32,
    a5: u32,
    a6: u32,
    a7: u32,
    s0: u32,
    s1: u32,
    s2: u32,
    s3: u32,
    s4: u32,
    s5: u32,
    s6: u32,
    s7: u32,
    s8: u32,
    s9: u32,
    s10: u32,
    s11: u32,
    sp: u32,
};

fn readCsr(comptime csr_name: []const u8) u32 {
    return asm volatile ("csrr %[out], " ++ csr_name
        : [out] "=r" (-> u32),
        :
        : .{} // no clobber
    );
}

fn writeCsr(comptime csr_name: []const u8, value: u32) void {
    asm volatile ("csrw " ++ csr_name ++ ", %[in]"
        :
        : [in] "r" (value),
        : .{} // no clobbers
    );
}
