when defined(archI386):
  import ../arch/i386/hal/cpu
  export cpu
elif defined(archAmd64):
  import ../arch/amd64/hal/cpu
  export cpu
else:
  {.error: "no supported architecture (archI386 or archAmd64)".}