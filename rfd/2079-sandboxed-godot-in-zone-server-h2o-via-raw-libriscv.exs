# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2079, "Sandboxed godot in zone server h2o via raw libriscv", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  `godot-riscv-spike` (RFD 2001 item 6) proved a real, full Godot engine
  instance boots and ticks inside `libriscv`'s own sandbox (`rvlinux`).
  This holds for the real sandbox, not just `qemu-riscv64`. Five real
  `libriscv` fixes made this work. Host-level `strace -f` confirmed the
  result. `syscalls.jsonld`'s own audit already named the target use
  case. The `socket` syscall's own note reads: "Relevant to CastSpell
  effects that talk to zone-server-h2o."
  :: related
  The full argument is in git at `a6eb679`.
  """
end
