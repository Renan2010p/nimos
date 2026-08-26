#[
    vga — Text Mode 80x25

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

    $Nimos: src/arch/i386/dev/vga.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/io
import ../../../hal/color

const
  VGA_WIDTH:  int     = 80
  VGA_HEIGHT: int     = 25
  VGA_BUFFER: uint32  = 0xB8000'u32
  VGA_ADDR:   uint16  = 0x3D4'u16

proc cursor_hide*(): void =
  outb(VGA_ADDR, 0x0A'u8)
  outb(VGA_ADDR + 1'u16, 0x20'u8)

var
  cursor_row*: int  = 0
  cursor_col*: int  = 0
  vga_attr: uint8   = uint8((ord(Black) shl 4) or ord(LightGrey))

var vga_buffer {.volatile.}: ptr array[VGA_WIDTH * VGA_HEIGHT, uint16] =
  cast[ptr array[VGA_WIDTH * VGA_HEIGHT, uint16]](VGA_BUFFER)

proc make_char*(ch: char, fg: Color, bg: Color): uint16 =
  return uint16(ch) or (uint16(ord(fg)) shl 8) or (uint16(ord(bg)) shl 12)

proc set_attr*(fg: Color, bg: Color): void =
  vga_attr = uint8((ord(bg) shl 4) or ord(fg))

proc clear*(): void =
  cursor_row = 0
  cursor_col = 0
  var i: int = 0
  while i < VGA_WIDTH * VGA_HEIGHT:
    vga_buffer[i] = make_char(' ', White, Black)
    i += 1

proc scroll_up*(): void =
  var i: int = 0
  while i < VGA_WIDTH * (VGA_HEIGHT - 1):
    vga_buffer[i] = vga_buffer[i + VGA_WIDTH]
    i += 1
  while i < VGA_WIDTH * VGA_HEIGHT:
    vga_buffer[i] = make_char(' ', White, Black)
    i += 1

proc newline*(): void =
  cursor_col = 0
  cursor_row += 1
  if cursor_row >= VGA_HEIGHT:
    scroll_up()
    cursor_row = VGA_HEIGHT - 1

proc put_char*(ch: char): void =
  case ch
  of '\n': newline()
  of '\r': cursor_col = 0
  of '\t': cursor_col = (cursor_col + 8) and not 7
  else:
    if cursor_col >= VGA_WIDTH:
      newline()
    let fg: Color = Color(vga_attr and 0x0F'u8)
    let bg: Color = Color((vga_attr shr 4) and 0x0F'u8)
    vga_buffer[cursor_row * VGA_WIDTH + cursor_col] = make_char(ch, fg, bg)
    cursor_col += 1

proc put_str*(s: string): void =
  var i: int = 0
  while i < s.len:
    put_char(s[i])
    i += 1

const HEX_DIGITS: array[16, char] = [
  '0', '1', '2', '3', '4', '5', '6', '7',
  '8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
]

proc put_hex*(v: uint32): void =
  put_str("0x")
  var started: bool = false
  var shift: int = 28
  while shift >= 0:
    let d: uint8 = uint8((v shr uint32(shift)) and 0xF'u32)
    if d != 0'u8:
      started = true
    if started:
      put_char(HEX_DIGITS[d])
    shift -= 4
  if not started:
    put_char('0')

proc put_uint*(v: uint32): void =
  var buf: array[10, char]
  var n: uint32 = v
  var i: int = 0
  if n == 0'u32:
    put_char('0')
    return
  while n > 0'u32:
    buf[i] = HEX_DIGITS[uint8(n mod 10'u32)]
    n = n div 10'u32
    i += 1
  var j: int = i - 1
  while j >= 0:
    put_char(buf[j])
    j -= 1

proc backspace*(): void =
  if cursor_col > 0:
    cursor_col -= 1
    let fg: Color = Color(vga_attr and 0x0F'u8)
    let bg: Color = Color((vga_attr shr 4) and 0x0F'u8)
    vga_buffer[cursor_row * VGA_WIDTH + cursor_col] = make_char(' ', fg, bg)

proc set_cursor*(row: int, col: int): void =
  cursor_row = row
  cursor_col = col

proc poke*(row: int, col: int, val: uint16): void =
  vga_buffer[row * VGA_WIDTH + col] = val

proc peek*(row: int, col: int): uint16 =
  return vga_buffer[row * VGA_WIDTH + col]
