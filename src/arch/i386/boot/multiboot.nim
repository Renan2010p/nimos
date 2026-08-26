#[
    multiboot — Multiboot 1 Boot Entry

    Copyright (C) 2026 Renan Lucas Vieira Hilario

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
    MA 02110-1301, USA.

    $Nimos: src/arch/i386/boot/multiboot.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/cpu
import ../tables/gdt
import ../tables/idt

const
  MB_MAGIC:   uint32 = 0x1BADB002'u32
  MB_FLAGS:   uint32 = 0x00'u32
  MB_CHECK:   uint32 = uint32(0) - (MB_MAGIC + MB_FLAGS)
  STACK_SIZE: int    = 16384

var mb_header {.codegenDecl: "__attribute__((section(\".multiboot\"), aligned(4))) $# $#".}: array[3, uint32] = [
  MB_MAGIC, MB_FLAGS, MB_CHECK,
]

var stack_bottom {.exportc: "nimos_stack", align: 16.}: array[STACK_SIZE, uint8]

proc gdt_init(): void {.exportc: "gdt_init", cdecl.} =
  gdt.init()

proc idt_init(): void {.exportc: "idt_init", cdecl.} =
  idt.init()

proc kernel_main(): void {.importc: "kernel_main", cdecl.}

proc start_kernel(): void {.exportc: "nimos_start_kernel", cdecl, noreturn.} =
  gdt_init()
  idt_init()
  kernel_main()
  cli()
  while true:
    halt()

proc kernel_entry(): void {.exportc: "_start", cdecl, asmNoStackFrame, noreturn.} =
  asm """
    movl $(nimos_stack + 16384), %esp
    pushl $0
    popfl
    call nimos_start_kernel
  """
