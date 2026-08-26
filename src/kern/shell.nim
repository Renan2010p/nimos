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

    $NisKo: src/kern/shell.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import platform

const
  MAX_LINE: int = 64

var
  line_buf:      array[MAX_LINE, char]
  line_len:      int         = 0
  shell_running: bool        = true

proc prompt(): void =
  set_attr(LightGreen, Black)
  put_str("nimk> ")
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

proc matches(start: int, length: int, s: string): bool =
  if length != s.len:
    return false
  var i: int = 0
  while i < length:
    if line_buf[start + i] != s[i]:
      return false
    i += 1
  return true

proc cmd_help(): void =
  set_attr(LightCyan, Black)
  put_str("Commands:")
  set_attr(LightGrey, Black)
  put_str("\n  help   - show this")
  put_str("\n  clear  - clear screen")
  put_str("\n  echo   - echo text")
  put_str("\n  halt   - halt CPU")
  put_str("\n  reboot - reboot system")
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

  if matches(s, cmd_len, "help"):
    cmd_help()
  elif matches(s, cmd_len, "clear"):
    clear()
  elif matches(s, cmd_len, "echo"):
    cmd_echo(a_start, a_len)
  elif matches(s, cmd_len, "halt"):
    cmd_halt()
  elif matches(s, cmd_len, "reboot"):
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
