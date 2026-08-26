#[
    keyboard — PS/2 Scan Code Set 1

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

    $Nimos: src/arch/i386/dev/keyboard.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/io

const
  PS2_STATUS: uint16 = 0x64'u16
  PS2_DATA:   uint16 = 0x60'u16

const SCAN_CODES: array[128, char] = [
  '\0',  '\x1B', '1', '2', '3', '4', '5', '6',
  '7',   '8',   '9', '0', '-', '=', '\b', '\t',
  'q',   'w',   'e', 'r', 't', 'y', 'u', 'i',
  'o',   'p',   '[', ']', '\n', '\0', 'a', 's',
  'd',   'f',   'g', 'h', 'j', 'k', 'l', ';',
  '\'',  '`',   '\0', '\\', 'z', 'x', 'c', 'v',
  'b',   'n',   'm', ',', '.', '/', '\0', '*',
  '\0',  ' ',   '\0', '\0', '\0', '\0', '\0', '\0',
  '\0',  '\0',  '\0', '\0', '\0', '\0', '\0', '7',
  '8',   '9',   '-', '4', '5', '6', '+', '1',
  '2',   '3',   '0', '.', '\0', '\0', '\0', '\0',
  '\0',  '\0',  '\0', '\0', '\0', '\0', '\0', '\0',
  '\0',  '\0',  '\0', '\0', '\0', '\0', '\0', '\0',
  '\0',  '\0',  '\0', '\0', '\0', '\0', '\0', '\0',
  '\0',  '\0',  '\0', '\0', '\0', '\0', '\0', '\0',
  '\0',  '\0',  '\0', '\0', '\0', '\0', '\0', '\0',
]

const SCAN_CODES_SHIFT: array[128, char] = [
  '\0',  '\x1B', '!', '@', '#', '$', '%', '^',
  '&',   '*',   '(', ')', '_', '+', '\b', '\t',
  'Q',   'W',   'E', 'R', 'T', 'Y', 'U', 'I',
  'O',   'P',   '{', '}', '\n', '\0', 'A', 'S',
  'D',   'F',   'G', 'H', 'J', 'K', 'L', ':',
  '"',   '~',   '\0', '|', 'Z', 'X', 'C', 'V',
  'B',   'N',   'M', '<', '>', '?', '\0', '*',
  '\0',  ' ',   '\0', '\0', '\0', '\0', '\0', '\0',
  '\0',  '\0',  '\0', '\0', '\0', '\0', '\0', '7',
  '8',   '9',   '-', '4', '5', '6', '+', '1',
  '2',   '3',   '0', '.', '\0', '\0', '\0', '\0',
  '\0',  '\0',  '\0', '\0', '\0', '\0', '\0', '\0',
  '\0',  '\0',  '\0', '\0', '\0', '\0', '\0', '\0',
  '\0',  '\0',  '\0', '\0', '\0', '\0', '\0', '\0',
  '\0',  '\0',  '\0', '\0', '\0', '\0', '\0', '\0',
  '\0',  '\0',  '\0', '\0', '\0', '\0', '\0', '\0',
]

var shift_held: bool = false

proc init*(): void =
  while (inb(PS2_STATUS) and 0x01'u8) != 0'u8:
    discard inb(PS2_DATA)

proc read_key*(): char =
  while (inb(PS2_STATUS) and 0x01'u8) == 0'u8:
    discard
  let sc: uint8 = inb(PS2_DATA)

  if sc >= 0x80'u8:
    let released: uint8 = sc and 0x7F'u8
    if released == 0x2A'u8 or released == 0x36'u8:
      shift_held = false
    return '\0'

  if sc == 0x2A'u8 or sc == 0x36'u8:
    shift_held = true
    return '\0'

  if shift_held:
    return SCAN_CODES_SHIFT[sc]
  else:
    return SCAN_CODES[sc]

proc has_key*(): bool =
  return (inb(PS2_STATUS) and 0x01'u8) != 0'u8
