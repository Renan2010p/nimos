#[
    mem — Freestanding Memory Routines

    Nim's generated C calls `memset`/`memcpy` to zero and copy
    arrays.  These are not provided by a freestanding libc, so we
    supply them here.

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

proc kernel_memset(dst: pointer, val: uint8, n: uint32): pointer {.exportc: "memset", cdecl.} =
  let base: uint32 = cast[uint32](dst)
  var i: uint32 = 0'u32
  while i < n:
    cast[ptr uint8](base + i)[] = val
    i += 1'u32
  return dst

proc kernel_memcpy(dst: pointer, src: pointer, n: uint32): pointer {.exportc: "memcpy", cdecl.} =
  let d: uint32 = cast[uint32](dst)
  let s: uint32 = cast[uint32](src)
  var i: uint32 = 0'u32
  while i < n:
    cast[ptr uint8](d + i)[] = cast[ptr uint8](s + i)[]
    i += 1'u32
  return dst

proc kernel_memmove(dst: pointer, src: pointer, n: uint32): pointer {.exportc: "memmove", cdecl.} =
  let d: uint32 = cast[uint32](dst)
  let s: uint32 = cast[uint32](src)
  if d < s:
    var i: uint32 = 0'u32
    while i < n:
      cast[ptr uint8](d + i)[] = cast[ptr uint8](s + i)[]
      i += 1'u32
  else:
    var i: uint32 = n
    while i > 0'u32:
      i -= 1'u32
      cast[ptr uint8](d + i)[] = cast[ptr uint8](s + i)[]
  return dst

proc kernel_memcmp(a: pointer, b: pointer, n: uint32): int {.exportc: "memcmp", cdecl.} =
  let p: uint32 = cast[uint32](a)
  let q: uint32 = cast[uint32](b)
  var i: uint32 = 0'u32
  while i < n:
    let x: uint8 = cast[ptr uint8](p + i)[]
    let y: uint8 = cast[ptr uint8](q + i)[]
    if x != y:
      return if x < y: -1 else: 1
    i += 1'u32
  return 0
