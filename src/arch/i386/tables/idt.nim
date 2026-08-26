#[
    idt — Interrupt Descriptor Table

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

    $NisKo: src/arch/i386/tables/idt.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/cpu
import ./pic

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

  pic.remap()
  lidt(cast[uint32](addr idt_ptr))
