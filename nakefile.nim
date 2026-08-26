#[
    nakefile — Nimos Build Tasks

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

    $Nimos: nakefile.nim,v 1.0 2026/08/26 00:00:00 renan Exp $
]#

import nake, os, std/algorithm

const
  Build    = "build"
  NimCache = Build / "nimcache"
  Kernel   = Build / "kernel"
  ISO      = Build / "nimos.iso"
  ISODir   = Build / "iso"
  Entry    = "src/main.nim"
  LDScript = "src/arch/i386/conf/kernel.ld"

  CC    = "clang"
  CFLAGS = "-m32 -ffreestanding -fno-stack-protector -mno-red-zone " &
           "-nostdlib -fno-pic -fno-pie -I/usr/lib/nim/lib/ -w"
  LD    = "ld.lld"
  LDFLAGS = "-m elf_i386 -nostdlib -T " & LDScript

  GRUBCFG = "set timeout=0\n" &
            "set default=0\n" &
            "menuentry \"Nimos\" {\n" &
            "    multiboot /boot/kernel\n" &
            "    boot\n" &
            "}\n"

task "clean", "Removes build files.":
  removeDir(Build)
  echo "Done."

task "build", "Compiles and links kernel.":
  if not dirExists(NimCache):
    createDir(NimCache)

  echo "  nim c --nimcache:" & NimCache & " --compileOnly " & Entry
  direShell nimExe, "c", "--nimcache:" & NimCache, "--compileOnly", Entry

  echo "  Compiling C..."
  var objs: seq[string] = @[]
  for f in walkFiles(NimCache / "*.c"):
    echo "  CC  " & f
    shell "sed -i 's/__attribute__((visibility(\"hidden\"))) //g' \"" & f & "\""
    let obj = f.changeFileExt("o")
    direShell CC, CFLAGS, "-c", f, "-o", obj
    objs.add(obj)
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
