const SBIRet = struct {
    err: isize,
    value: isize,
};

pub fn sbi_call(
    arg0: usize,
    arg1: usize,
    arg2: usize,
    arg3: usize,
    arg4: usize,
    arg5: usize,
    fid: usize,
    eid: usize,
) SBIRet {
    var out0: usize = 0;
    var out1: usize = 0;

    asm volatile ("ecall"
        : [o0] "={a0}" (out0),
          [o1] "={a1}" (out1),
        : [i0] "{a0}" (arg0),
          [i1] "{a1}" (arg1),
          [i2] "{a2}" (arg2),
          [i3] "{a3}" (arg3),
          [i4] "{a4}" (arg4),
          [i5] "{a5}" (arg5),
          [i6] "{a6}" (fid),
          [i7] "{a7}" (eid),
        : .{ .memory = true });

    return .{
        .err = @bitCast(out0),
        .value = @bitCast(out1),
    };
}

pub fn putchar(ch: u8) void {
    _ = sbi_call(ch, 0, 0, 0, 0, 0, 0, 1);
}
