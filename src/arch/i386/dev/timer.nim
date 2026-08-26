#[
    timer — 8254 Programmable Interval Timer

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

    $Nimos: src/arch/i386/dev/timer.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/cpu
import ../tables/irq
import ../tables/pic

const
  PIT_CHANNEL0: uint16 = 0x40'u16
  PIT_CMD:      uint16 = 0x43'u16
  PIT_FREQ:     uint32 = 1193182'u32

var
  tick_count: uint32 = 0

proc tick(): void {.cdecl.} =
  tick_count += 1'u32

proc init*(freq: uint32): void =
  var divisor: uint32 = PIT_FREQ div freq
  if divisor < 2'u32:
    divisor = 2'u32
  if divisor > 65535'u32:
    divisor = 65535'u32
  outb(PIT_CMD, 0x36'u8)
  outb(PIT_CHANNEL0, uint8(divisor and 0xFF'u32))
  outb(PIT_CHANNEL0, uint8((divisor shr 8) and 0xFF'u32))
  irq.register(0, tick)
  pic.unmask(0)

proc ticks*(): uint32 =
  return tick_count

proc sleep*(ms: uint32): void =
  let start: uint32 = tick_count
  while tick_count - start < ms:
    halt()
