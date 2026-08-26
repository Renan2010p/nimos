#[
    console

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

import ../dev/vga as vga_dev
import ../../../hal/color as color_hal

export vga_dev.clear
export vga_dev.set_attr
export vga_dev.put_char
export vga_dev.put_str
export vga_dev.put_hex
export vga_dev.put_uint
export vga_dev.backspace
export vga_dev.cursor_hide
export vga_dev.set_cursor
export vga_dev.cursor_row
export vga_dev.cursor_col
export color_hal.Color

proc draw_char*(row: int, col: int, ch: char, fg: Color, bg: Color): void =
  vga_dev.poke(row, col, vga_dev.make_char(ch, fg, bg))