#!/bin/sh
#
# build.sh — Nimos Build Script
#
# Copyright (c) 2026 Renan Lucas Vieira Hilario
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# $Nimos: build.sh,v 1.0 2026/08/26 00:00:00 renan Exp $
#

set -e

BUILD="build"
NIMCACHE="$BUILD/nimcache"
KERNEL="$BUILD/kernel.elf"
ENTRY="src/main.nim"
LDSCRIPT="src/arch/i386/conf/kernel.ld"

CFLAGS="-m32 -ffreestanding -fno-stack-protector -mno-red-zone -nostdlib \
  -I/usr/lib/nim/lib/ -w"

LDFLAGS="-m elf_i386 -nostdlib -T $LDSCRIPT"

build() {
    echo "Building Nimos..."
    mkdir -p "$NIMCACHE"

    echo "  nim c --nimcache:$NIMCACHE --compileOnly $ENTRY"
    nim c --nimcache:$NIMCACHE --compileOnly $ENTRY

    echo "  Compiling C..."
    for f in "$NIMCACHE"/*.c; do
        echo "  CC  $f"
        sed -i 's/__attribute__((visibility("hidden"))) //g' "$f"
        clang $CFLAGS -c "$f" -o "${f%.c}.o"
    done

    echo "  Linking $KERNEL"
    ld.lld $LDFLAGS "$NIMCACHE"/*.o -o "$KERNEL"
    echo "Done: $KERNEL ($(stat -c%s "$KERNEL") bytes)"
}

clean() {
    echo "Cleaning..."
    rm -rf "$BUILD"
}

case "${1:-}" in
    clean)  clean ;;
    run)
        build
        echo "  qemu-system-i386 -kernel $KERNEL"
        qemu-system-i386 -kernel "$KERNEL"
        ;;
    "")     build ;;
    *)      echo "Usage: ./build.sh [clean|run]"; exit 1 ;;
esac
