#[
    pic — 8259 Programmable Interrupt Controller

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

    $Nimos: src/arch/i386/tables/pic.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import ../cpu/cpu

var
  pic_mask: uint16 = 0xFFFF'u16

proc set_mask(mask: uint16): void =
  outb(0x21'u16, uint8(mask and 0xFF'u16))
  io_wait()
  outb(0xA1'u16, uint8((mask shr 8) and 0xFF'u16))

proc remap*(): void =
  outb(0x20'u16, 0x11'u8)
  io_wait()
  outb(0xA0'u16, 0x11'u8)
  io_wait()
  outb(0x21'u16, 0x20'u8)
  io_wait()
  outb(0xA1'u16, 0x28'u8)
  io_wait()
  outb(0x21'u16, 0x04'u8)
  io_wait()
  outb(0xA1'u16, 0x02'u8)
  io_wait()
  outb(0x21'u16, 0x01'u8)
  io_wait()
  outb(0xA1'u16, 0x01'u8)
  io_wait()
  pic_mask = 0xFFFF'u16
  set_mask(pic_mask)

proc unmask*(irq: uint8): void =
  if irq < 16'u8:
    pic_mask = pic_mask and not (uint16(1) shl int(irq))
    set_mask(pic_mask)
