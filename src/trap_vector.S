    .section .text.trap, "ax"
    .globl trap_vector
    .align 12
trap_vector:
    j kernelEntry

