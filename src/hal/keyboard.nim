when defined(archI386):
  import ../arch/i386/hal/keyboard
  export keyboard
elif defined(archAmd64):
  import ../arch/amd64/hal/keyboard
  export keyboard
else:
  {.error: "no supported architecture (archI386 or archAmd64)".}