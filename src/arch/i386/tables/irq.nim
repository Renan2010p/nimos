#[
    irq — PIC Hardware Interrupt Handlers

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

    $Nimos: src/arch/i386/tables/irq.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/cpu
import ./isr
import std/macros

type
  IrqHandler = proc(): void {.cdecl.}

const IRQ_OFFSET: uint32 = 32'u32

var
  handlers: array[16, IrqHandler]

proc register*(irq: int, handler: IrqHandler): void =
  if irq >= 0 and irq < 16:
    handlers[irq] = handler

asm """
.section .text
.globl irq_common_stub
irq_common_stub:
    cli
    pusha
    push %ds
    push %es
    push %fs
    push %gs
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %esp, %eax
    push %eax
    call irq_handler
    add $4, %esp
    pop %gs
    pop %fs
    pop %es
    pop %ds
    popa
    add $8, %esp
    iret
"""

macro gen_irq_stubs: untyped =
  result = newStmtList()
  for i in 0 ..< 16:
    let name = "irq" & $i
    let vec = 32 + i
    result.add(parseStmt(
      "asm \"\"\"\n.section .text\n.globl " & name & "\n" &
      name & ":\n    cli\n    push $0\n    push $" & $vec &
      "\n    jmp irq_common_stub\n\"\"\"\n" &
      "proc " & name & "(): void {.importc: \"" & name & "\", cdecl.}\n"
    ))

gen_irq_stubs()

proc irq_handler(frame: ptr CpuState): void {.exportc: "irq_handler", cdecl.} =
  let n: int = int(frame.int_no - IRQ_OFFSET)
  if n >= 0 and n < 16 and handlers[n] != nil:
    handlers[n]()

  if frame.int_no >= 40'u32:
    outb(0xA0'u16, 0x20'u8)
  outb(0x20'u16, 0x20'u8)

proc get_irq_addr*(num: int): uint32 =
  case num
  of 0:  cast[uint32](irq0)
  of 1:  cast[uint32](irq1)
  of 2:  cast[uint32](irq2)
  of 3:  cast[uint32](irq3)
  of 4:  cast[uint32](irq4)
  of 5:  cast[uint32](irq5)
  of 6:  cast[uint32](irq6)
  of 7:  cast[uint32](irq7)
  of 8:  cast[uint32](irq8)
  of 9:  cast[uint32](irq9)
  of 10: cast[uint32](irq10)
  of 11: cast[uint32](irq11)
  of 12: cast[uint32](irq12)
  of 13: cast[uint32](irq13)
  of 14: cast[uint32](irq14)
  of 15: cast[uint32](irq15)
  else:  0'u32
