#[
    platform — Architecture Facade

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

    $Nimos: src/platform.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

{.warning[UnusedImport]: off.}

when defined(archAmd64):
  {.error: "amd64 not implemented".}

else:
  import arch/i386/cpu/cpu
  import arch/i386/dev/vga
  import arch/i386/dev/keyboard
  import arch/i386/boot/multiboot

  export cpu.halt
  export cpu.reboot
  export cpu.nop
  export vga.clear
  export vga.set_attr
  export vga.put_char
  export vga.put_str
  export vga.backspace
  export vga.cursor_hide
  export vga.set_cursor
  export vga.cursor_row
  export vga.cursor_col
  export vga.poke
  export vga.peek
  export keyboard.init
  export keyboard.has_key
  export keyboard.read_key
  export VgaColor
