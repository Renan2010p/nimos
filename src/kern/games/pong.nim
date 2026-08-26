#[
    pong — Pong Game

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

    $Nimos: src/kern/games/pong.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../../platform

const
  WIDTH:    int = 80
  HEIGHT:   int = 25
  PADDLE_H: int = 4
  SPEED:    int = 40000

var
  ball_x:   int
  ball_y:   int
  ball_dx:  int
  ball_dy:  int
  left_y:   int
  right_y:  int
  score_l:  int
  score_r:  int
  running:  bool

proc ch(ch: char, fg: VgaColor): uint16 =
  return uint16(ch) or (uint16(ord(fg)) shl 8) or (uint16(ord(Black)) shl 12)

proc delay(ticks: int): void =
  var i: int = 0
  while i < ticks:
    nop()
    i += 1

proc clear_screen(): void =
  var y: int = 0
  while y < HEIGHT:
    var x: int = 0
    while x < WIDTH:
      poke(y, x, ch(' ', Black))
      x += 1
    y += 1

proc draw(): void =
  clear_screen()

  var i: int = 0
  while i < HEIGHT:
    poke(i, WIDTH div 2, ch('|', DarkGrey))
    i += 1

  poke(ball_y, ball_x, ch('o', White))

  i = 0
  while i < PADDLE_H:
    poke(left_y + i, 1, ch('#', LightGreen))
    poke(right_y + i, WIDTH - 2, ch('#', LightRed))
    i += 1

  poke(0, 36, ch(chr(48 + score_l), Yellow))
  poke(0, 37, ch(':', Yellow))
  poke(0, 38, ch(chr(48 + score_r), Yellow))

  poke(HEIGHT - 1, 25, ch('W', LightGrey))
  poke(HEIGHT - 1, 26, ch('/', LightGrey))
  poke(HEIGHT - 1, 27, ch('S', LightGrey))
  poke(HEIGHT - 1, 28, ch(' ', LightGrey))
  poke(HEIGHT - 1, 29, ch('l', LightGrey))
  poke(HEIGHT - 1, 30, ch('e', LightGrey))
  poke(HEIGHT - 1, 31, ch('f', LightGrey))
  poke(HEIGHT - 1, 32, ch('t', LightGrey))
  poke(HEIGHT - 1, 33, ch(' ', LightGrey))
  poke(HEIGHT - 1, 34, ch('|', LightGrey))
  poke(HEIGHT - 1, 35, ch(' ', LightGrey))
  poke(HEIGHT - 1, 36, ch('I', LightGrey))
  poke(HEIGHT - 1, 37, ch('/', LightGrey))
  poke(HEIGHT - 1, 38, ch('K', LightGrey))
  poke(HEIGHT - 1, 39, ch(' ', LightGrey))
  poke(HEIGHT - 1, 40, ch('r', LightGrey))
  poke(HEIGHT - 1, 41, ch('i', LightGrey))
  poke(HEIGHT - 1, 42, ch('g', LightGrey))
  poke(HEIGHT - 1, 43, ch('h', LightGrey))
  poke(HEIGHT - 1, 44, ch('t', LightGrey))

proc input(): void =
  while has_key():
    let c: char = read_key()
    case c
    of 'w', 'W':
      if left_y > 0: left_y -= 1
    of 's', 'S':
      if left_y < HEIGHT - PADDLE_H: left_y += 1
    of 'i', 'I':
      if right_y > 0: right_y -= 1
    of 'k', 'K':
      if right_y < HEIGHT - PADDLE_H: right_y += 1
    of 'q', 'Q':
      running = false
    else:
      discard

proc step(): void =
  ball_x += ball_dx
  ball_y += ball_dy

  if ball_y <= 0 or ball_y >= HEIGHT - 1:
    ball_dy = -ball_dy

  if ball_x == 2:
    if ball_y >= left_y and ball_y < left_y + PADDLE_H:
      ball_dx = 1
    else:
      score_r += 1
      ball_x = WIDTH div 2
      ball_y = HEIGHT div 2
      ball_dx = 1
      ball_dy = 1

  if ball_x == WIDTH - 3:
    if ball_y >= right_y and ball_y < right_y + PADDLE_H:
      ball_dx = -1
    else:
      score_l += 1
      ball_x = WIDTH div 2
      ball_y = HEIGHT div 2
      ball_dx = -1
      ball_dy = 1

  if score_l >= 9 or score_r >= 9:
    running = false

proc run*(): void =
  ball_x = WIDTH div 2
  ball_y = HEIGHT div 2
  ball_dx = 1
  ball_dy = 1
  left_y = HEIGHT div 2 - PADDLE_H div 2
  right_y = HEIGHT div 2 - PADDLE_H div 2
  score_l = 0
  score_r = 0
  running = true

  while running:
    input()
    step()
    draw()
    delay(SPEED)

  clear()
  set_attr(Yellow, Black)
  if score_l >= 9:
    set_cursor(12, 30)
    put_str("LEFT PLAYER WINS!")
  else:
    set_cursor(12, 30)
    put_str("RIGHT PLAYER WINS!")
  set_cursor(14, 30)
  put_str("Press any key...")
  discard read_key()
