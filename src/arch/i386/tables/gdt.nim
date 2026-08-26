#[
    gdt — Global Descriptor Table

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

    $Nimos: src/arch/i386/tables/gdt.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
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
