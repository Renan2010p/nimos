import ../dev/timer as timer_dev

proc init_timer*(freq: uint32): void =
  timer_dev.init(freq)

export timer_dev.ticks
export timer_dev.sleep