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