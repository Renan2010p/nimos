#[
    shell — Interactive Command Line

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

import ../../platform
import ./cmd

var
  line_buf:      array[MaxLine, char]
  line_len:      int         = 0
  shell_running: bool        = true

proc prompt(): void =
  set_attr(Green, Black)
  put_str("nimos> ")
  set_attr(LightGrey, Black)

proc reset_line(): void =
  line_len = 0

proc handle_backspace(): void =
  if line_len > 0:
    line_len -= 1
    backspace()

proc append_char(c: char): void =
  if line_len < MaxLine:
    line_buf[line_len] = c
    line_len += 1
    put_char(c)

proc run*(): void =
  init()
  prompt()

  while shell_running:
    if not has_key():
      continue
    let c: char = read_key()
    case c
    of '\0':
      discard
    of '\n':
      put_char('\n')
      cmd.process_command(line_buf, line_len)
      reset_line()
      prompt()
    of '\b':
      handle_backspace()
    of '\x1B':
      discard
    else:
      append_char(c)