#[
    cmd — Shell Command Implementations

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
import ../games/snake
import ../games/tictactoe
import ../games/pong

const MaxLine* = 64

proc matches4(buf: array[MaxLine, char], start: int, length: int, a: char, b: char, c: char, d: char): bool =
  return length == 4 and buf[start] == a and buf[start + 1] == b and buf[start + 2] == c and buf[start + 3] == d

proc matches5(buf: array[MaxLine, char], start: int, length: int, a: char, b: char, c: char, d: char, e: char): bool =
  return length == 5 and buf[start] == a and buf[start + 1] == b and buf[start + 2] == c and buf[start + 3] == d and buf[start + 4] == e

proc matches6(buf: array[MaxLine, char], start: int, length: int, a: char, b: char, c: char, d: char, e: char, f: char): bool =
  return length == 6 and buf[start] == a and buf[start + 1] == b and buf[start + 2] == c and buf[start + 3] == d and buf[start + 4] == e and buf[start + 5] == f

proc cmd_help(): void =
  set_attr(LightCyan, Black)
  put_str("Commands:")
  set_attr(LightGrey, Black)
  put_str("\n  help    - show this")
  put_str("\n  clear   - clear screen")
  put_str("\n  echo    - echo text")
  put_str("\n  games   - play games")
  put_str("\n  uptime  - show time since boot")
  put_str("\n  ticks   - show timer ticks")
  put_str("\n  halt    - halt CPU")
  put_str("\n  reboot  - reboot system")
  put_str("\n")

proc cmd_uptime(): void =
  let t: uint32 = ticks()
  let secs: uint32 = t div 1000'u32
  put_str("Up ")
  put_uint(secs div 3600'u32)
  put_str("h ")
  put_uint((secs div 60'u32) mod 60'u32)
  put_str("m ")
  put_uint(secs mod 60'u32)
  put_str("s\n")

proc cmd_ticks(): void =
  put_str("Ticks: ")
  put_uint(ticks())
  put_char('\n')

proc cmd_echo(buf: array[MaxLine, char], args_start: int, args_len: int): void =
  var i: int = 0
  while i < args_len:
    put_char(buf[args_start + i])
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

proc process_command*(buf: array[MaxLine, char], line_len: int): void =
  var s: int = 0
  while s < line_len and buf[s] == ' ':
    s += 1
  if s >= line_len:
    return

  var e: int = s
  while e < line_len and buf[e] != ' ':
    e += 1
  let cmd_len: int = e - s

  var a_start: int = e
  if a_start < line_len and buf[a_start] == ' ':
    a_start += 1
  let a_len: int = line_len - a_start

  if matches4(buf, s, cmd_len, 'h', 'e', 'l', 'p'):
    cmd_help()
  elif matches5(buf, s, cmd_len, 'c', 'l', 'e', 'a', 'r'):
    clear()
  elif matches4(buf, s, cmd_len, 'e', 'c', 'h', 'o'):
    cmd_echo(buf, a_start, a_len)
  elif matches6(buf, s, cmd_len, 'u', 'p', 't', 'i', 'm', 'e'):
    cmd_uptime()
  elif matches5(buf, s, cmd_len, 't', 'i', 'c', 'k', 's'):
    cmd_ticks()
  elif matches5(buf, s, cmd_len, 'g', 'a', 'm', 'e', 's'):
    cmd_games()
  elif matches4(buf, s, cmd_len, 'h', 'a', 'l', 't'):
    cmd_halt()
  elif matches6(buf, s, cmd_len, 'r', 'e', 'b', 'o', 'o', 't'):
    cmd_reboot()
  else:
    set_attr(Yellow, Black)
    put_str("Unknown: ")
    var i: int = 0
    while i < cmd_len:
      put_char(buf[s + i])
      i += 1
    put_char('\n')
    set_attr(LightGrey, Black)