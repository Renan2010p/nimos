#[
    io — Port I/O

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