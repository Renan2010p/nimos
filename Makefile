NIM     = nim
CC      = clang
LD      = ld.lld
BUILD   = build

NIMFLAGS = --nimcache:$(BUILD)/nimcache --compileOnly

CFLAGS = -m32 -ffreestanding -fno-stack-protector -mno-red-zone -nostdlib \
         -I/usr/lib/nim/lib/ -w

LDFLAGS = -m elf_i386 -nostdlib -T src/arch/i386/conf/kernel.ld

.PHONY: all clean run

all: $(BUILD)/kernel.elf

$(BUILD):
	mkdir -p $(BUILD)/nimcache

$(BUILD)/kernel.elf: | $(BUILD)
	$(NIM) c $(NIMFLAGS) src/main.nim
	@for f in $(BUILD)/nimcache/*.c; do \
		echo "  CC  $$f"; \
		sed -i 's/__attribute__((visibility("hidden"))) //g' $$f; \
		$(CC) $(CFLAGS) -c $$f -o $${f%.c}.o; \
	done
	$(LD) $(LDFLAGS) $(BUILD)/nimcache/*.o -o $@

run: $(BUILD)/kernel.elf
	qemu-system-i386 -kernel $<

clean:
	rm -rf $(BUILD)
