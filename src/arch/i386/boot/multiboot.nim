#[
    multiboot — Multiboot 1 Boot Entry

    Copyright (c) 2026 Renan Lucas Vieira Hilario
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
    IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
    IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
    NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
    THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
