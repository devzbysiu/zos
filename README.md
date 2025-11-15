<div align="center">

  <h1><code>zOS</code></h1>

  <h3>
    <strong>A minimal Zig kernel for RISC-V, built from scratch</strong>
  </h3>

  <h3>
    <a href="#overview">Overview</a>
    <span> | </span>
    <a href="#features">Features</a>
    <span> | </span>
    <a href="#how">How it works</a>
    <span> | </span>
    <a href="#run">Running it</a>
    <span> | </span>
    <a href="#license">License</a>
  </h3>

  <sub><h4>Built with Zig ⚡</h4></sub>

  <img src="https://img.shields.io/badge/language-Zig-f7a41d?style=for-the-badge&logo=zig" />
  <img src="https://img.shields.io/badge/architecture-RISC--V-1e63c1?style=for-the-badge&logo=risc-v" />
  <img src="https://img.shields.io/badge/bootloader-OpenSBI-4b8300?style=for-the-badge" />
</div>

## <p id="overview">🚀 Overview</p>

**zOS** is a small educational kernel written in **Zig**,
targeting **RISC-V** (RV32).
It is designed to be *simple, readable, and hackable*, showing how to
bring up a system from bare metal all the way to handling traps and
making SBI calls.

### 🎯 Goals

- Show how to write a tiny kernel\
- Be easy to read, learn from, and experiment with\
- Provide a minimal but real trap pipeline and allocator\
- Demonstrate using Zig in a bare-metal environment\

### 🧩 Built With

- **Zig** --- low-level programming without fear
- **RISC-V / RV32** --- clean and open architecture
- **OpenSBI** --- standard interface for firmware/syscalls
- **QEMU** --- fast virtual RISC-V environment

## <p id="features">✨ Features</p>

### 🧵 Boot Process

- Custom linker script sets the entry symbol (`boot`)
- First code executed is `_start()` function
- Stack pointer is initialized manually
- Control is transferred cleanly to `kernelMain()`

### 💬 Console Output

- Minimal `putchar()` implemented through **OpenSBI ecall**
- A tiny, compile-time-formatted `printf()` + `log()` implementation
- Prints hex/decimal/string without relying on the standard library

### ⚠️ Trap Handling

- A fully custom trap vector:
  - `trap_vector.S` aligns the handler correctly
  - Jumps into a Zig `kernelEntry` function
- `kernelEntry`:
  - Saves all registers manually
  - Calls `handleTrap` with a well-defined `TrapFrame`
  - Restores registers and executes `sret`
- Trap debugging includes:
  - `scause`
  - `stval`
  - `sepc`

### 📦 Memory Management

- Extremely simple **linear allocator**:
  - Allocates whole pages
  - Zeros allocations with `memset`
  - Pointer range validated using linker-defined symbols:
    - `__free_ram`
    - `__free_ram_end`
- Helpful for early boot and experimentation

## <p id="how">🧠 How It Works</p>

### 🔹 1. Boot Entry

The linker script defines `ENTRY(boot)`, and the `.text.boot` section
contains:

``` zig
pub export fn _start() linksection(".text.boot") callconv(.naked) noreturn {...}
```

This function:

1. Initializes `next_addr` for the allocator
2. Sets up the stack pointer
3. Jumps to `kernelMain`

### 🔹 2. Kernel Main Logic

Inside `kernelMain`:

- Install trap vector (`stvec`)
- Test allocator (`allocPages`)
- Print system state
- Enter low-power `wfi` loop

### 🔹 3. Trap Handling Pipeline

```plaintext
Exception → stvec register → trap_vector.S → kernelEntry → handleTrap()
```

- Fully manual context save & restore
- Clean C-ABI trap handler in Zig
- Prints a panic with CSR information

### 🔹 4. Memory Layout

The linker defines:

```plaintext
[text | rodata | data | bss] → stack → RAM (64 MB)
```

Key exported symbols:

```plaintext
__stack_top       # initial stack pointer
__free_ram        # start of free RAM allocator
__free_ram_end    # allocator limit
```

## <p id="run">▶️ Running It</p>

You can run the kernel under **QEMU**: `./run.sh`

Ensure OpenSBI firmware is present (default QEMU uses one automatically).

### 🧪 Example Output

```bash
[*] starting kernel...
[*] trap vector address: 0x80203000
[*] allocPages test: paddr0=0x80220000
[*] allocPages test: paddr1=0x80222000
[*] continuing execution...
```

And if something traps:

```bash
[*] trap scause=0x00000002, stval=0x00000000, sepc=0x80200420
[*]     in: kernel.zig:123
```

## <p id="license">⭐ License</p>

This project is licensed under either of

- Apache License, Version 2.0, (LICENSE-APACHE or <http://www.apache.org/licenses/LICENSE-2.0>)
- MIT license (LICENSE-MIT or <http://opensource.org/licenses/MIT>)

at your option.
