# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2081, "Three layer verification strategy", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  | Layer | Tool | Scope | What it proves | | --------------- |
  --------------------- | -------------- |
  ------------------------------------------------------------ | | C
  invariants | CBMC | Implementation | SPSC ring FIFO, bounds,
  head-tail, NURand range | | Specification | Lean 4 | Design | SPSC
  linearizability, push/pop preserve bounds | | TPC-C semantics |
  plausible-witness-dag | Runtime | NewOrder atomicity, Delivery
  correctness, Stock non-negative |
  :: related
  The full argument is in git at `a6eb679`.
  """
end
