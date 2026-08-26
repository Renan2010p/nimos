#[
    nakefile — Nimos Build Tasks

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

    $Nimos: nakefile.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import nake, os, std/algorithm, std/osproc, std/cpuinfo, std/streams

const
  Build    = "build"
  NimCache = Build / "nimcache"
  Kernel   = Build / "kernel"
  ISO      = Build / "nimos.iso"
  ISODir   = Build / "iso"
  Entry    = "src/main.nim"
  LDScript = "src/arch/i386/conf/kernel.ld"

  CCARG = "cc"
  CFLAGS = "-target x86-freestanding-eabi -ffreestanding -fno-stack-protector " &
           "-mno-red-zone -fno-pic -fno-pie -fno-sanitize=all -g0 " &
           "-I/usr/lib/nim/lib/ -Isrc/arch/i386/conf -w"
  LD    = "zig ld.lld"
  LDFLAGS = "-m elf_i386 -nostdlib -T " & LDScript

  GRUBCFG = "set timeout=0\n" &
            "set default=0\n" &
            "menuentry \"Nimos\" {\n" &
            "    multiboot /boot/kernel\n" &
            "    boot\n" &
            "}\n"

let zigExe = "/usr/bin/zig"

task "clean", "Removes build files.":
  removeDir(Build)
  echo "Done."

task "build", "Compiles and links kernel.":
  if not dirExists(NimCache):
    createDir(NimCache)

  echo "  nim c --nimcache:" & NimCache & " --compileOnly " & Entry
  direShell nimExe, "c", "--nimcache:" & NimCache, "--compileOnly", Entry

  echo "  Compiling C (" & $cpuinfo.countProcessors() & " parallel jobs)..."
  var jobs = cpuinfo.countProcessors()
  var objs: seq[string] = @[]
  var files: seq[string] = @[]
  for f in walkFiles(NimCache / "*.c"):
    files.add(f)
  files.sort()

  var procs: seq[(Process, string)] = @[]
  var idx = 0
  while idx < files.len or procs.len > 0:
    while procs.len < jobs and idx < files.len:
      let f = files[idx]
      let obj = f.changeFileExt("o")
      echo "  CC  " & f
      let args = @[CCARG] & CFLAGS.splitWhitespace() & @["-c", f, "-o", obj]
      procs.add((startProcess(zigExe, args = args), obj))
      idx += 1
    var i = 0
    while i < procs.len:
      let ec = procs[i][0].peekExitCode()
      if ec != -1:
        let output = procs[i][0].outputStream.readAll()
        procs[i][0].close()
        if ec != 0:
          echo output
          quit 1
        objs.add(procs[i][1])
        procs.del(i)
      else:
        i += 1
    if procs.len >= jobs or idx >= files.len:
      sleep(50)
  objs.sort()

  echo "  Linking " & Kernel
  direShell LD, LDFLAGS, objs.join(" "), "-o", Kernel
  echo "Done: " & Kernel & " (" & $getFileSize(Kernel) & " bytes)"

task "iso", "Builds a bootable ISO image.":
  runTask("build")
  echo "  Validating Multiboot header..."
  if not shell("grub-file --is-x86-multiboot " & Kernel):
    echo "ERROR: " & Kernel & " is not a valid Multiboot 1 image"
    quit 1
  echo "  Staging ISO tree..."
  removeDir(ISODir)
  createDir(ISODir / "boot" / "grub")
  copyFile(Kernel, ISODir / "boot" / "kernel")
  writeFile(ISODir / "boot" / "grub" / "grub.cfg", GRUBCFG)
  echo "  grub-mkrescue -o " & ISO & " " & ISODir
  direShell "grub-mkrescue", "-o", ISO, ISODir
  echo "Done: " & ISO & " (" & $getFileSize(ISO) & " bytes)"

task "run", "Builds and runs kernel in QEMU.":
  runTask("build")
  echo "  qemu-system-i386 -kernel " & Kernel
  direShell "qemu-system-i386", "-kernel", Kernel

task "run-iso", "Builds ISO and runs it in QEMU.":
  runTask("iso")
  echo "  qemu-system-i386 -cdrom " & ISO
  direShell "qemu-system-i386", "-cdrom", ISO

task "default", "Builds kernel.":
  runTask("build")
