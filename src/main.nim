#[
    Nimos Kernel — i386 Multiboot1 Entry Point

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

    $Nimos: src/main.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import platform
import kern/shell

proc kernel_main(): void {.exportc, cdecl.} =
  clear()
  cursor_hide()

  init_timer(1000)
  sti()

  set_attr(LightCyan, Black)
  put_str("Nimos v0.1")
  set_attr(LightGrey, Black)
  put_str(" — i386 multiboot\n")
  put_str("Type 'help' for commands.\n\n")

  shell.run()
