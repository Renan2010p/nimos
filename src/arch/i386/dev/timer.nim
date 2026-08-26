#[
    timer — 8254 Programmable Interval Timer

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

    $Nimos: src/arch/i386/dev/timer.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/cpu
import ../tables/irq
import ../tables/pic

const
  PIT_CHANNEL0: uint16 = 0x40'u16
  PIT_CMD:      uint16 = 0x43'u16
  PIT_FREQ:     uint32 = 1193182'u32

var
  tick_count: uint32 = 0

proc tick(): void {.cdecl.} =
  tick_count += 1'u32

proc init*(freq: uint32): void =
  var divisor: uint32 = PIT_FREQ div freq
  if divisor < 2'u32:
    divisor = 2'u32
  if divisor > 65535'u32:
    divisor = 65535'u32
  outb(PIT_CMD, 0x36'u8)
  outb(PIT_CHANNEL0, uint8(divisor and 0xFF'u32))
  outb(PIT_CHANNEL0, uint8((divisor shr 8) and 0xFF'u32))
  irq.register(0, tick)
  pic.unmask(0)

proc ticks*(): uint32 =
  return tick_count

proc sleep*(ms: uint32): void =
  let start: uint32 = tick_count
  while tick_count - start < ms:
    halt()
