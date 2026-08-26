#[
    shell — Interactive Command Line

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

    $Nimos: src/kern/shell.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import platform
import games/snake
import games/tictactoe
import games/pong

const
  MAX_LINE: int = 64

var
  line_buf:      array[MAX_LINE, char]
  line_len:      int         = 0
  shell_running: bool        = true

proc prompt(): void =
  set_attr(LightGreen, Black)
  put_str("# ")
  set_attr(LightGrey, Black)

proc reset_line(): void =
  line_len = 0

proc handle_backspace(): void =
  if line_len > 0:
    line_len -= 1
    backspace()

proc append_char(c: char): void =
  if line_len < MAX_LINE:
    line_buf[line_len] = c
    line_len += 1
    put_char(c)

proc matches_cmd(start: int, length: int, a: char, b: char): bool =
  return length == 2 and line_buf[start] == a and line_buf[start + 1] == b

proc matches3(start: int, length: int, a: char, b: char, c: char): bool =
  return length == 3 and line_buf[start] == a and line_buf[start + 1] == b and line_buf[start + 2] == c

proc matches4(start: int, length: int, a: char, b: char, c: char, d: char): bool =
  return length == 4 and line_buf[start] == a and line_buf[start + 1] == b and line_buf[start + 2] == c and line_buf[start + 3] == d

proc matches5(start: int, length: int, a: char, b: char, c: char, d: char, e: char): bool =
  return length == 5 and line_buf[start] == a and line_buf[start + 1] == b and line_buf[start + 2] == c and line_buf[start + 3] == d and line_buf[start + 4] == e

proc matches6(start: int, length: int, a: char, b: char, c: char, d: char, e: char, f: char): bool =
  return length == 6 and line_buf[start] == a and line_buf[start + 1] == b and line_buf[start + 2] == c and line_buf[start + 3] == d and line_buf[start + 4] == e and line_buf[start + 5] == f

proc cmd_help(): void =
  set_attr(LightCyan, Black)
  put_str("Commands:")
  set_attr(LightGrey, Black)
  put_str("\n  help    - show this")
  put_str("\n  clear   - clear screen")
  put_str("\n  echo    - echo text")
  put_str("\n  games   - play games")
  put_str("\n  halt    - halt CPU")
  put_str("\n  reboot  - reboot system")
  put_str("\n")

proc cmd_echo(args_start: int, args_len: int): void =
  var i: int = 0
  while i < args_len:
    put_char(line_buf[args_start + i])
    i += 1
  put_char('\n')

proc cmd_halt(): void =
  set_attr(LightRed, Black)
  put_str("System halted.\n")
  halt()

proc cmd_reboot(): void =
  reboot()

proc cmd_games(): void =
  clear()
  set_attr(LightCyan, Black)
  put_str("  Games\n\n")
  set_attr(White, Black)
  put_str("  1) Snake\n")
  put_str("  2) Tic-Tac-Toe\n")
  put_str("  3) Pong\n")
  put_str("\n")
  set_attr(LightGrey, Black)
  put_str("  Select (1-3): ")

  while not has_key():
    discard
  let c: char = read_key()
  put_char(c)
  put_str("\n")

  case c
  of '1': snake.run()
  of '2': tictactoe.run()
  of '3': pong.run()
  else:
    set_attr(Yellow, Black)
    put_str("  Invalid option.\n")
    put_str("  Press any key...")
    discard read_key()

proc process_command(): void =
  var s: int = 0
  while s < line_len and line_buf[s] == ' ':
    s += 1
  if s >= line_len:
    return

  var e: int = s
  while e < line_len and line_buf[e] != ' ':
    e += 1
  let cmd_len: int = e - s

  var a_start: int = e
  if a_start < line_len and line_buf[a_start] == ' ':
    a_start += 1
  let a_len: int = line_len - a_start

  if matches4(s, cmd_len, 'h', 'e', 'l', 'p'):
    cmd_help()
  elif matches5(s, cmd_len, 'c', 'l', 'e', 'a', 'r'):
    clear()
  elif matches4(s, cmd_len, 'e', 'c', 'h', 'o'):
    cmd_echo(a_start, a_len)
  elif matches5(s, cmd_len, 'g', 'a', 'm', 'e', 's'):
    cmd_games()
  elif matches4(s, cmd_len, 'h', 'a', 'l', 't'):
    cmd_halt()
  elif matches6(s, cmd_len, 'r', 'e', 'b', 'o', 'o', 't'):
    cmd_reboot()
  else:
    set_attr(Yellow, Black)
    put_str("Unknown: ")
    var i: int = 0
    while i < cmd_len:
      put_char(line_buf[s + i])
      i += 1
    put_char('\n')
    set_attr(LightGrey, Black)

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
      process_command()
      reset_line()
      prompt()
    of '\b':
      handle_backspace()
    of '\x1B':
      discard
    else:
      append_char(c)
