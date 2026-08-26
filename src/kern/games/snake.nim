#[
    snake — Classic Snake Game

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

    $Nimos: src/kern/games/snake.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../../platform

const
  FIELD_W: int = 40
  FIELD_H: int = 20
  MAX_LEN: int = 200
  SPEED:   int = 80000

type
  Direction = enum
    DirUp, DirDown, DirLeft, DirRight

var
  snake_x:  array[MAX_LEN, int]
  snake_y:  array[MAX_LEN, int]
  snake_len: int
  food_x:   int
  food_y:   int
  dir:      Direction
  score:    int
  alive:    bool

proc ch(ch: char, fg: VgaColor): uint16 =
  return uint16(ch) or (uint16(ord(fg)) shl 8) or (uint16(ord(Black)) shl 12)

proc delay(ticks: int): void =
  var i: int = 0
  while i < ticks:
    nop()
    i += 1

proc put(r: int, c: int, val: uint16): void =
  poke(r, c, val)

proc draw_border(): void =
  var x: int = 0
  while x < FIELD_W + 2:
    put(0, x, ch('-', LightGrey))
    put(FIELD_H + 1, x, ch('-', LightGrey))
    x += 1
  var y: int = 0
  while y < FIELD_H + 2:
    put(y, 0, ch('|', LightGrey))
    put(y, FIELD_W + 1, ch('|', LightGrey))
    y += 1

proc draw_field(): void =
  var y: int = 0
  while y < FIELD_H:
    var x: int = 0
    while x < FIELD_W:
      put(y + 1, x + 1, ch(' ', Black))
      x += 1
    y += 1

proc place_food(): void =
  food_x = 5
  food_y = 5

proc draw_food(): void =
  put(food_y + 1, food_x + 1, ch('*', Red))

proc draw_snake(): void =
  var i: int = 0
  while i < snake_len:
    let c: char = if i == 0: '@' else: 'o'
    let col: VgaColor = if i == 0: LightGreen else: Green
    put(snake_y[i] + 1, snake_x[i] + 1, ch(c, col))
    i += 1

proc draw_digit(row: int, col: int, d: int): void =
  put(row, col, ch(chr(48 + d), White))

proc draw_score(): void =
  put(0, 0, ch('S', Yellow))
  put(0, 1, ch('c', Yellow))
  put(0, 2, ch('o', Yellow))
  put(0, 3, ch('r', Yellow))
  put(0, 4, ch('e', Yellow))
  put(0, 5, ch(':', Yellow))
  let s: int = score
  draw_digit(0, 6, s div 100)
  draw_digit(0, 7, (s div 10) mod 10)
  draw_digit(0, 8, s mod 10)

proc check_collision(): bool =
  if snake_x[0] < 0 or snake_x[0] >= FIELD_W:
    return true
  if snake_y[0] < 0 or snake_y[0] >= FIELD_H:
    return true
  var i: int = 1
  while i < snake_len:
    if snake_x[0] == snake_x[i] and snake_y[0] == snake_y[i]:
      return true
    i += 1
  return false

proc read_input(): void =
  while has_key():
    let c: char = read_key()
    case c
    of 'w', 'W':
      if dir != DirDown: dir = DirUp
    of 's', 'S':
      if dir != DirUp: dir = DirDown
    of 'a', 'A':
      if dir != DirRight: dir = DirLeft
    of 'd', 'D':
      if dir != DirLeft: dir = DirRight
    of 'q', 'Q':
      alive = false
    else:
      discard

proc step(): void =
  var i: int = snake_len - 1
  while i > 0:
    snake_x[i] = snake_x[i - 1]
    snake_y[i] = snake_y[i - 1]
    i -= 1

  case dir
  of DirUp:    snake_y[0] -= 1
  of DirDown:  snake_y[0] += 1
  of DirLeft:  snake_x[0] -= 1
  of DirRight: snake_x[0] += 1

  if snake_x[0] == food_x and snake_y[0] == food_y:
    if snake_len < MAX_LEN:
      snake_len += 1
    score += 10
    place_food()


proc run*(): void =
  clear()
  snake_len = 3
  snake_x[0] = 5;  snake_y[0] = 5
  snake_x[1] = 4;  snake_y[1] = 5
  snake_x[2] = 3;  snake_y[2] = 5
  dir = DirRight
  score = 0
  alive = true

  draw_border()
  place_food()

  while alive:
    read_input()
    step()
    if check_collision():
      alive = false
      break
    draw_field()
    draw_food()
    draw_snake()
    draw_score()
    delay(SPEED)

  set_attr(LightRed, Black)
  set_cursor(12, 15)
  put_str("GAME OVER!")
  set_cursor(13, 15)
  put_str("Score: ")
  let s: int = score
  draw_digit(13, 22, s div 100)
  draw_digit(13, 23, (s div 10) mod 10)
  draw_digit(13, 24, s mod 10)
  set_cursor(14, 15)
  put_str("Press any key...")
  discard read_key()
