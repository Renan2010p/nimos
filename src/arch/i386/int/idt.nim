#[
    idt — Interrupt Descriptor Table

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

    $Nimos: src/arch/i386/int/idt.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/inst
import ./pic
import ./isr
import ./irq

type
  IdtEntry {.packed.} = object
    base_low:  uint16
    sel:       uint16
    always0:   uint8
    flags:     uint8
    base_high: uint16

  IdtPtr {.packed.} = object
    limit: uint16
    base:  uint32

var
  idt_entries: array[256, IdtEntry]
  idt_ptr: IdtPtr

proc set_gate*(num: uint8, base: uint32, sel: uint16, flags: uint8): void =
  idt_entries[num].base_low  = uint16(base and 0xFFFF'u32)
  idt_entries[num].base_high = uint16((base shr 16) and 0xFFFF'u32)
  idt_entries[num].sel       = sel
  idt_entries[num].always0   = 0'u8
  idt_entries[num].flags     = flags

proc init*(): void =
  idt_ptr.limit = uint16(sizeof(IdtEntry) * 256 - 1)
  idt_ptr.base  = cast[uint32](addr idt_entries[0])

  let base_addr: uint32 = cast[uint32](addr idt_entries[0])
  var i: uint32 = 0'u32
  while i < uint32(sizeof(IdtEntry) * 256):
    cast[ptr uint8](base_addr + i)[] = 0'u8
    i += 1'u32

  var j: int = 0
  while j < 32:
    idt.set_gate(uint8(j), isr.get_isr_addr(j), 0x08'u16, 0x8E'u8)
    j += 1

  j = 0
  while j < 16:
    idt.set_gate(uint8(32 + j), irq.get_irq_addr(j), 0x08'u16, 0x8E'u8)
    j += 1

  pic.remap()
  lidt(cast[uint32](addr idt_ptr))
