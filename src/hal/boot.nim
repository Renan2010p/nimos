when defined(archI386):
  import ../arch/i386/boot/multiboot
  export multiboot
elif defined(archAmd64):
  import ../arch/amd64/boot/multiboot
  export multiboot
else:
  {.error: "no supported architecture (archI386 or archAmd64)".}