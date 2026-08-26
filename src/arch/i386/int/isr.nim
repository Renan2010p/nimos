#[
    isr — CPU Exception Handlers

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
]#

import ../cpu/inst
import ../dev/vga
import ../../../hal/color
import std/macros

type
  CpuState* {.packed.} = object
    gs*:       uint32
    fs*:       uint32
    es*:       uint32
    ds*:       uint32
    edi*:      uint32
    esi*:      uint32
    ebp*:      uint32
    esp*:      uint32
    ebx*:      uint32
    edx*:      uint32
    ecx*:      uint32
    eax*:      uint32
    int_no*:   uint32
    err_code*: uint32
    eip*:      uint32
    cs*:       uint32
    eflags*:   uint32
    useresp*:  uint32
    ss*:       uint32

asm """
.section .text
.globl isr_common_stub
isr_common_stub:
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
    call isr_handler
    add $4, %esp
    pop %gs
    pop %fs
    pop %es
    pop %ds
    popa
    add $8, %esp
    iret
"""

macro gen_isr_stubs: untyped =
  result = newStmtList()
  for i in 0 ..< 32:
    let name = "isr" & $i
    let has_err = i == 8 or i == 10 or i == 11 or
                  i == 12 or i == 13 or i == 14 or i == 17
    let body = if has_err:
      "  push $" & $i & "\n"
    else:
      "  push $0\n  push $" & $i & "\n"

    result.add(parseStmt(
      "asm \"\"\"\n.section .text\n.globl " & name & "\n" &
      name & ":\n    cli\n" & body & "    jmp isr_common_stub\n\"\"\"\n" &
      "proc " & name & "(): void {.importc: \"" & name & "\", cdecl.}\n"
    ))

gen_isr_stubs()

const EXCEPTION_NAMES: array[32, string] = [
  "Division By Zero", "Debug", "Non Maskable Interrupt", "Breakpoint",
  "Overflow", "Bound Range Exceeded", "Invalid Opcode", "Device Not Available",
  "Double Fault", "Coprocessor Segment Overrun", "Invalid TSS",
  "Segment Not Present", "Stack-Segment Fault", "General Protection Fault",
  "Page Fault", "Reserved", "x87 Floating-Point Exception",
  "Alignment Check", "Machine Check", "SIMD Floating-Point Exception",
  "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved",
  "Reserved", "Reserved", "Reserved", "Reserved", "Security Exception",
  "Reserved",
]

proc isr_handler(frame: ptr CpuState): void {.exportc: "isr_handler", cdecl.} =
  let n: int = int(frame.int_no)
  set_attr(LightRed, Black)
  put_str("\nKERNEL EXCEPTION: ")
  if n >= 0 and n < 32:
    put_str(EXCEPTION_NAMES[n])
  else:
    put_str("Unknown")
  put_str("\n  eip=")
  put_hex(frame.eip)
  put_str("  cs=")
  put_hex(frame.cs)
  put_str("  eflags=")
  put_hex(frame.eflags)
  put_str("\n  err=")
  put_hex(frame.err_code)
  put_str("\n  eax=")
  put_hex(frame.eax)
  put_str("  ebx=")
  put_hex(frame.ebx)
  put_str("  ecx=")
  put_hex(frame.ecx)
  put_str("  edx=")
  put_hex(frame.edx)
  put_str("\n  esi=")
  put_hex(frame.esi)
  put_str("  edi=")
  put_hex(frame.edi)
  put_str("  ebp=")
  put_hex(frame.ebp)
  put_str("\nSystem halted.\n")
  set_attr(LightGrey, Black)
  halt()

proc get_isr_addr*(num: int): uint32 =
  case num
  of 0:  cast[uint32](isr0)
  of 1:  cast[uint32](isr1)
  of 2:  cast[uint32](isr2)
  of 3:  cast[uint32](isr3)
  of 4:  cast[uint32](isr4)
  of 5:  cast[uint32](isr5)
  of 6:  cast[uint32](isr6)
  of 7:  cast[uint32](isr7)
  of 8:  cast[uint32](isr8)
  of 9:  cast[uint32](isr9)
  of 10: cast[uint32](isr10)
  of 11: cast[uint32](isr11)
  of 12: cast[uint32](isr12)
  of 13: cast[uint32](isr13)
  of 14: cast[uint32](isr14)
  of 15: cast[uint32](isr15)
  of 16: cast[uint32](isr16)
  of 17: cast[uint32](isr17)
  of 18: cast[uint32](isr18)
  of 19: cast[uint32](isr19)
  of 20: cast[uint32](isr20)
  of 21: cast[uint32](isr21)
  of 22: cast[uint32](isr22)
  of 23: cast[uint32](isr23)
  of 24: cast[uint32](isr24)
  of 25: cast[uint32](isr25)
  of 26: cast[uint32](isr26)
  of 27: cast[uint32](isr27)
  of 28: cast[uint32](isr28)
  of 29: cast[uint32](isr29)
  of 30: cast[uint32](isr30)
  of 31: cast[uint32](isr31)
  else:  0'u32