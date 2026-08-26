#[
    keyboard — PS/2 Scan Code Set 1

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

    $NisKo: src/arch/i386/dev/keyboard.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/cpu

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
