#[
    multiboot — Boot Assembly

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

    $NisKo: src/arch/i386/boot/multiboot.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../tables/gdt
import ../tables/idt

asm """
.section .multiboot, "a"
.align 4
.long 0x1BADB002
.long 0x00
.long -(0x1BADB002 + 0x00)

.section .bss
.align 16
stack_bottom:
    .skip 16384
stack_top:

.section .text
.globl _start
.extern kernel_main
_start:
    movl $stack_top, %esp
    pushl $0
    popfl
    call gdt_init
    call idt_init
    call kernel_main
.hang:
    cli
    hlt
    jmp .hang
"""

proc gdt_init(): void {.exportc: "gdt_init", cdecl.} =
  gdt.init()

proc idt_init(): void {.exportc: "idt_init", cdecl.} =
  idt.init()
