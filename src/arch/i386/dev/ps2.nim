#[
    ps2 — PS/2 Controller

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

    $Nimos: src/arch/i386/dev/ps2.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/io

const
  PS2_STATUS: uint16 = 0x64'u16
  PS2_DATA:   uint16 = 0x60'u16

proc wait_read*(): void =
  while (inb(PS2_STATUS) and 0x02'u8) != 0'u8:
    discard inb(PS2_STATUS)

proc wait_write*(): void =
  while (inb(PS2_STATUS) and 0x01'u8) != 0'u8:
    discard inb(PS2_STATUS)

proc write*(val: uint8): void =
  wait_write()
  outb(PS2_DATA, val)

proc read*(): uint8 =
  wait_read()
  return inb(PS2_DATA)
