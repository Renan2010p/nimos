#[
    pic — 8259 Programmable Interrupt Controller

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

    $Nimos: src/arch/i386/int/pic.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/io

var
  pic_mask: uint16 = 0xFFFF'u16

proc set_mask(mask: uint16): void =
  outb(0x21'u16, uint8(mask and 0xFF'u16))
  io_wait()
  outb(0xA1'u16, uint8((mask shr 8) and 0xFF'u16))

proc remap*(): void =
  outb(0x20'u16, 0x11'u8)
  io_wait()
  outb(0xA0'u16, 0x11'u8)
  io_wait()
  outb(0x21'u16, 0x20'u8)
  io_wait()
  outb(0xA1'u16, 0x28'u8)
  io_wait()
  outb(0x21'u16, 0x04'u8)
  io_wait()
  outb(0xA1'u16, 0x02'u8)
  io_wait()
  outb(0x21'u16, 0x01'u8)
  io_wait()
  outb(0xA1'u16, 0x01'u8)
  io_wait()
  pic_mask = 0xFFFF'u16
  set_mask(pic_mask)

proc unmask*(irq: uint8): void =
  if irq < 16'u8:
    pic_mask = pic_mask and not (uint16(1) shl int(irq))
    set_mask(pic_mask)
