# Nimos

Um kernel para i386 (32 bits) escrito em [Nim](https://nim-lang.org), com interface
Multiboot 1, HAL próprio e um pequeno shell interativo com jogos.

## Requisitos

- [Nim](https://nim-lang.org) (>= 2.0)
- [nake](https://github.com/fowlmouth/nake) (`nimble install nake`)
- [Zig](https://ziglang.org) (compilador C e linker)
- [GRUB](https://www.gnu.org/software/grub/) (para gerar a ISO)
- [QEMU](https://www.qemu.org) (para testar)

## Compilação

```sh
nake build      # compila e gera build/kernel
nake iso        # gera build/nimos.iso (ISO inicializável)
nake clean      # remove o diretório build/
```

A compilação dos arquivos C gerados pelo Nim é feita em paralelo, usando todos os
núcleos da CPU. O kernel gerado segue a especificação Multiboot 1.

## Executando

```sh
nake iso
qemu-system-i386 -cdrom build/nimos.iso
```

Ou, para um boot direto pelo kernel:

```sh
qemu-system-i386 -kernel build/kernel
```

## Recursos

- Multiboot 1 (boot pelo GRUB)
- HAL: console (VGA text mode), teclado (PS/2), timer (PIT)
- GDT, IDT, ISR, IRQ e remapeamento do PIC
- Shell interativo com os comandos: `help`, `clear`, `echo`, `uptime`,
  `ticks`, `games`, `halt` e `reboot`
- Jogos: Snake, Tic-Tac-Toe e Pong

## Estrutura

```
src/
├── main.nim              # entry point (Multiboot 1)
├── platform.nim          # agrega a plataforma (HAL + kernel)
├── hal/                  # abstrações independentes de arquitetura
├── arch/i386/            # implementação i386
│   ├── boot/             # cabeçalho Multiboot
│   ├── cpu/              # GDT/IDT/ISR/IRQ/PIC
│   ├── dev/              # VGA, teclado, timer
│   ├── hal/              # HAL concreto (console, teclado, timer, cpu)
│   └── conf/             # linker script e stubs freestanding
└── kern/
    ├── shell.nim         # shell interativo
    └── games/            # snake, tictactoe, pong
```

## Licença

Distribuído sob a [GNU General Public License v2.0](LICENSE).
