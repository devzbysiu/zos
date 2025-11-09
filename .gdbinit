set arch riscv:rv32
file zig-out/bin/kernel.elf
target remote :1234
b _start
c
