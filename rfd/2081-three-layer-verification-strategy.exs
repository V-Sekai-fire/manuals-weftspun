# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2081. `mix rfd.render` renders rfd/2081-three-layer-verification-strategy/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2081 do
  use RFD.DSL

  rfd 2081, "Three layer verification strategy" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    | Layer | Tool | Scope | What it proves | | --------------- |
    --------------------- | -------------- |
    ------------------------------------------------------------ | | C
    invariants | CBMC | Implementation | SPSC ring FIFO, bounds,
    head-tail, NURand range | | Specification | Lean 4 | Design | SPSC
    linearizability, push/pop preserve bounds | | TPC-C semantics |
    plausible-witness-dag | Runtime | NewOrder atomicity, Delivery
    correctness, Stock non-negative |
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
