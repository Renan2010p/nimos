#[
    vga — Text Mode 80x25

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

    $Nimos: src/arch/i386/dev/vga.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/cpu

type
  VgaColor* = enum
    Black        = 0
    Blue         = 1
    Green        = 2
    Cyan         = 3
    Red          = 4
    Magenta      = 5
    Brown        = 6
    LightGrey    = 7
    DarkGrey     = 8
    LightBlue    = 9
    LightGreen   = 10
    LightCyan    = 11
    LightRed     = 12
    LightMagenta = 13
    Yellow       = 14
    White        = 15

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

proc make_char(ch: char, fg: VgaColor, bg: VgaColor): uint16 =
  return uint16(ch) or (uint16(ord(fg)) shl 8) or (uint16(ord(bg)) shl 12)

proc set_attr*(fg: VgaColor, bg: VgaColor): void =
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
    let fg: VgaColor = VgaColor(vga_attr and 0x0F'u8)
    let bg: VgaColor = VgaColor((vga_attr shr 4) and 0x0F'u8)
    vga_buffer[cursor_row * VGA_WIDTH + cursor_col] = make_char(ch, fg, bg)
    cursor_col += 1

proc put_str*(s: string): void =
  var i: int = 0
  while i < s.len:
    put_char(s[i])
    i += 1

proc backspace*(): void =
  if cursor_col > 0:
    cursor_col -= 1
    let fg: VgaColor = VgaColor(vga_attr and 0x0F'u8)
    let bg: VgaColor = VgaColor((vga_attr shr 4) and 0x0F'u8)
    vga_buffer[cursor_row * VGA_WIDTH + cursor_col] = make_char(' ', fg, bg)

proc set_cursor*(row: int, col: int): void =
  cursor_row = row
  cursor_col = col

proc poke*(row: int, col: int, val: uint16): void =
  vga_buffer[row * VGA_WIDTH + col] = val

proc peek*(row: int, col: int): uint16 =
  return vga_buffer[row * VGA_WIDTH + col]
