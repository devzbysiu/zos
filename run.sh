#!/usr/bin/env bash
set -xue

QEMU=qemu-system-riscv32

zig build

${QEMU} \
  -machine virt \
  -bios default \
  -nographic \
  -serial mon:stdio \
  --no-reboot \
  -kernel zig-out/bin/kernel.elf
  # -S -s \ # stop and expose debugger
