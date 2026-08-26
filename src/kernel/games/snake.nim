#[
    snake — Classic Snake Game

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

    $Nimos: src/kernel/games/snake.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
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

proc delay(ticks: int): void =
  var i: int = 0
  while i < ticks:
    nop()
    i += 1

proc draw_border(): void =
  var x: int = 0
  while x < FIELD_W + 2:
    draw_char(0, x, '-', LightGrey, Black)
    draw_char(FIELD_H + 1, x, '-', LightGrey, Black)
    x += 1
  var y: int = 0
  while y < FIELD_H + 2:
    draw_char(y, 0, '|', LightGrey, Black)
    draw_char(y, FIELD_W + 1, '|', LightGrey, Black)
    y += 1

proc draw_field(): void =
  var y: int = 0
  while y < FIELD_H:
    var x: int = 0
    while x < FIELD_W:
      draw_char(y + 1, x + 1, ' ', Black, Black)
      x += 1
    y += 1

proc place_food(): void =
  food_x = 5
  food_y = 5

proc draw_food(): void =
  draw_char(food_y + 1, food_x + 1, '*', Red, Black)

proc draw_snake(): void =
  var i: int = 0
  while i < snake_len:
    let c: char = if i == 0: '@' else: 'o'
    let col: Color = if i == 0: LightGreen else: Green
    draw_char(snake_y[i] + 1, snake_x[i] + 1, c, col, Black)
    i += 1

proc draw_digit(row: int, col: int, d: int): void =
  draw_char(row, col, chr(48 + d), White, Black)

proc draw_score(): void =
  draw_char(0, 0, 'S', Yellow, Black)
  draw_char(0, 1, 'c', Yellow, Black)
  draw_char(0, 2, 'o', Yellow, Black)
  draw_char(0, 3, 'r', Yellow, Black)
  draw_char(0, 4, 'e', Yellow, Black)
  draw_char(0, 5, ':', Yellow, Black)
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
