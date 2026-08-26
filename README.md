# Nimos

[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)](LICENSE)
[![Language: Nim](https://img.shields.io/badge/Language-Nim-yellow)](https://nim-lang.org)
[![Target: i386](https://img.shields.io/badge/Target-i386-green)](https://wiki.osdev.org/Main_Page)

A **hobby operating system kernel** for the i386 architecture, written in [Nim](https://nim-lang.org).  
It boots via the **Multiboot 1** protocol, features a hardware abstraction layer (HAL), an interactive shell, and a few built-in terminal games.

Nimos is built with **Nim → C → Zig**, compiling the Nim-generated C files in parallel using all available CPU cores.

## Features

- **Multiboot 1** compliant — boots with GRUB or any Multiboot-compatible loader
- **HAL** — abstracted console (VGA text mode), PS/2 keyboard, and PIT timer
- **x86 segmentation and interrupts** — GDT, IDT, ISR, IRQ, and PIC remapping
- **Interactive shell** — commands: `help`, `clear`, `echo`, `uptime`, `ticks`, `games`, `halt`, `reboot`
- **Built-in games** — Snake, Tic-Tac-Toe, and Pong
- **Parallel C compilation** — all generated C files are compiled concurrently using `countProcessors()` workers
- **Freestanding** — no libc; provides custom `memset`/`memcpy`/`memmove` stubs

## Requirements

| Tool     | Version | Purpose                  |
|----------|---------|--------------------------|
| [Nim]    | >= 2.0  | Compiler                 |
| [nake]   | latest  | Build system (`nimble install nake`) |
| [Zig]    | latest  | C compiler (`zig cc`) and linker (`zig ld.lld`) |
| [GRUB]   | >= 2.0  | ISO image creation        |
| [QEMU]   | any     | Emulation / testing       |

[Nim]: https://nim-lang.org
[nake]: https://github.com/fowlmouth/nake
[Zig]: https://ziglang.org
[GRUB]: https://www.gnu.org/software/grub/
[QEMU]: https://www.qemu.org

## Quick Start

```sh
git clone git@github.com:Renan2010p/nimos.git
cd nimos

nake build      # compile the kernel → build/kernel
nake iso        # build + create a bootable ISO → build/nimos.iso
nake run        # build + launch in QEMU
nake run-iso    # build ISO + launch in QEMU
nake clean      # remove build artifacts
```

### Testing in QEMU

```sh
nake run-iso
```

Or directly:

```sh
qemu-system-i386 -kernel build/kernel
```

## Build System

The project uses [nake](https://github.com/fowlmouth/nake) as its build system (`nakefile.nim`).  
The build pipeline is:

1. **Nim → C** — `nim c --compileOnly` generates C sources from the Nim source tree
2. **C → object files** — all generated `.c` files are compiled with `zig cc` in parallel
3. **Link** — `zig ld.lld` links the object files into the final ELF kernel

C compilation flags are configured for a **freestanding i386** target with no sanitizers, no stack protector, no PIC/PIE, and no red zone.

## Architecture

```
src/
├── main.nim               # Entry point → kernel/init.setup()
├── panicoverride.nim       # Nim panic handler (required by --panics:off)
├── nim.cfg                 # Nim compiler configuration
│
├── kernel/                 # Core kernel
│   ├── init.nim            # Initialization sequence (subsystems, banner)
│   ├── version.nim         # Kernel version constants
│   └── shell/              # Interactive shell
│       ├── shell.nim       # Input loop and line editing
│       └── cmd.nim         # Command implementations and dispatch
│
├── hal/                    # Architecture-independent HAL interfaces
│   ├── console.nim
│   ├── keyboard.nim
│   ├── timer.nim
│   ├── cpu.nim
│   ├── color.nim
│   └── boot.nim
│
├── arch/i386/              # i386 architecture implementation
│   ├── boot/multiboot.nim  # Multiboot 1 header + entry point
│   ├── cpu/                # Port I/O, CPU instructions, memory routines
│   │   ├── io.nim
│   │   ├── inst.nim
│   │   └── mem.nim
│   ├── dev/                # VGA text mode, PS/2 keyboard, PIT timer, PS/2 controller
│   ├── hal/                # Concrete HAL (wraps dev/)
│   ├── int/                # Interrupt handling: GDT, IDT, ISR, IRQ, PIC
│   └── conf/               # Linker script, freestanding stubs
│
└── kern/                   # Kernel services
    └── games/              # Snake, Tic-Tac-Toe, Pong
```

## Command Reference

| Command    | Description                    |
|------------|--------------------------------|
| `help`     | Display available commands     |
| `clear`    | Clear the VGA text screen      |
| `echo`     | Print text to the console      |
| `uptime`   | Show time elapsed since boot   |
| `ticks`    | Show total PIT timer ticks     |
| `games`    | Launch the game menu           |
| `halt`     | Halt the CPU                   |
| `reboot`   | Reboot the system              |

## License

This project is distributed under the **GNU General Public License v2.0**.  
See [LICENSE](LICENSE) for details.

---

*Built with [Nim](https://nim-lang.org) and [Zig](https://ziglang.org).*