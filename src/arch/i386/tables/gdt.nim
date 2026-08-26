#[
    gdt — Global Descriptor Table

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

    $NisKo: src/arch/i386/tables/gdt.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/cpu

type
  GdtEntry {.packed.} = object
    limit_low:    uint16
    base_low:     uint16
    base_mid:     uint8
    access:       uint8
    granularity:  uint8
    base_high:    uint8

  GdtPtr {.packed.} = object
    limit: uint16
    base:  uint32

var
  gdt_entries: array[3, GdtEntry]
  gdt_ptr: GdtPtr

proc set_gate(num: int, base: uint32, limit: uint32, access: uint8, granularity: uint8): void =
  gdt_entries[num].base_low     = uint16(base and 0xFFFF'u32)
  gdt_entries[num].base_mid     = uint8((base shr 16) and 0xFF'u32)
  gdt_entries[num].base_high    = uint8((base shr 24) and 0xFF'u32)
  gdt_entries[num].limit_low    = uint16(limit and 0xFFFF'u32)
  gdt_entries[num].granularity  = uint8(((limit shr 16) and 0x0F'u32) or (granularity and 0xF0'u8))
  gdt_entries[num].access       = access

proc init*(): void =
  gdt_ptr.limit = uint16(sizeof(GdtEntry) * 3 - 1)
  gdt_ptr.base  = cast[uint32](addr gdt_entries[0])

  set_gate(0, 0'u32, 0'u32, 0'u8, 0'u8)
  set_gate(1, 0'u32, 0xFFFFFFFF'u32, 0x9A'u8, 0xCF'u8)
  set_gate(2, 0'u32, 0xFFFFFFFF'u32, 0x92'u8, 0xCF'u8)

  lgdt(cast[uint32](addr gdt_ptr))
