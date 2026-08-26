#[
    inst — CPU Instructions

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

import ./io
{.push warning[UnusedImport]: off.}
import ./mem
{.pop.}

proc halt*(): void {.inline.} =
  asm """
    cli
    hlt
  """

proc cli*(): void {.inline.} =
  asm """
    cli
  """

proc sti*(): void {.inline.} =
  asm """
    sti
  """

proc nop*(): void {.inline.} =
  asm """
    nop
  """

proc reboot*(): void =
  outb(0x64'u16, 0xFE'u8)

asm """
.code32
.globl cpu_lgdt
cpu_lgdt:
    movl 4(%esp), %eax
    lgdt (%eax)
    ljmp $0x08, $1f
1:
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss
    ret
"""
proc lgdt*(base: uint32): void {.importc: "cpu_lgdt", cdecl.}

asm """
.code32
.globl cpu_lidt
cpu_lidt:
    movl 4(%esp), %eax
    lidt (%eax)
    ret
"""
proc lidt*(base: uint32): void {.importc: "cpu_lidt", cdecl.}