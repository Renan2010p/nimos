#[
    cpu — Machine Instructions

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

    $Nimos: src/arch/i386/cpu/cpu.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ./mem

proc outb*(port: uint16, val: uint8): void {.inline.} =
  asm """
    outb %0, %1
    :
    : "a"(`val`), "Nd"(`port`)
  """

proc inb*(port: uint16): uint8 =
  asm """
    inb %1, %0
    : "=a"(`result`)
    : "Nd"(`port`)
  """

proc io_wait*(): void {.inline.} =
  outb(0x80'u16, 0'u8)

proc halt*(): void {.inline.} =
  asm """
    cli
    hlt
  """

proc cli*(): void {.inline.} =
  asm """
    cli
  """

proc sti*(): void {.inline.} =
  asm """
    sti
  """

proc nop*(): void {.inline.} =
  asm """
    nop
  """

proc reboot*(): void =
  outb(0x64'u16, 0xFE'u8)

asm """
.code32
.globl cpu_lgdt
cpu_lgdt:
    movl 4(%esp), %eax
    lgdt (%eax)
    ljmp $0x08, $1f
1:
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss
    ret
"""
proc lgdt*(base: uint32): void {.importc: "cpu_lgdt", cdecl.}

asm """
.code32
.globl cpu_lidt
cpu_lidt:
    movl 4(%esp), %eax
    lidt (%eax)
    ret
"""
proc lidt*(base: uint32): void {.importc: "cpu_lidt", cdecl.}
