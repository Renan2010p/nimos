#[
    tictactoe — Tic-Tac-Toe Game

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

    $Nimos: src/kern/games/tictactoe.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../../platform

var
  board: array[9, char]
  current: char
  moves: int

proc clear_board(): void =
  var i: int = 0
  while i < 9:
    board[i] = ' '
    i += 1
  current = 'X'
  moves = 0

proc draw(): void =
  clear()
  set_attr(LightCyan, Black)
  put_str("  Tic-Tac-Toe\n\n")
  set_attr(LightGrey, Black)
  put_str("  Player 1: X    Player 2: O\n\n")

  var row: int = 0
  while row < 3:
    set_attr(White, Black)
    put_str("       ")
    var col: int = 0
    while col < 3:
      let idx: int = row * 3 + col
      let ch: char = board[idx]
      case ch
      of 'X': set_attr(LightRed, Black)
      of 'O': set_attr(LightBlue, Black)
      else:  set_attr(LightGrey, Black)
      put_str(" ")
      put_char(ch)
      put_str(" ")
      if col < 2:
        set_attr(LightGrey, Black)
        put_str("|")
      col += 1
    put_str("\n")
    if row < 2:
      set_attr(LightGrey, Black)
      put_str("       ---+---+---\n")
    row += 1

  put_str("\n")
  set_attr(LightGrey, Black)
  put_str("  Moves: ")
  let m: int = moves
  put_char(chr(48 + m))
  put_str("/9\n")

proc check_win(): char =
  const lines: array[8, array[3, int]] = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6]
  ]
  var i: int = 0
  while i < 8:
    let a: int = lines[i][0]
    let b: int = lines[i][1]
    let c: int = lines[i][2]
    if board[a] != ' ' and board[a] == board[b] and board[b] == board[c]:
      return board[a]
    i += 1
  return ' '

proc run*(): void =
  clear_board()

  while true:
    draw()

    let winner: char = check_win()
    if winner != ' ':
      set_attr(Yellow, Black)
      put_str("  Player ")
      put_char(winner)
      put_str(" wins!\n")
      put_str("  Press any key...")
      discard read_key()
      return

    if moves >= 9:
      set_attr(Yellow, Black)
      put_str("  Draw!\n")
      put_str("  Press any key...")
      discard read_key()
      return

    set_attr(LightGreen, Black)
    put_str("  Player ")
    put_char(current)
    put_str("'s turn (1-9): ")

    while not has_key():
      discard
    let c: char = read_key()

    if c < '1' or c > '9':
      continue

    let pos: int = int(c) - int('1')
    if board[pos] != ' ':
      continue

    board[pos] = current
    moves += 1

    if current == 'X':
      current = 'O'
    else:
      current = 'X'
