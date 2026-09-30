# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2086. `mix rfd.render` renders rfd/2086-defer-nogod-gossip-zone-authority/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2086 do
  use RFD.DSL

  rfd 2086, "Defer nogod gossip zone authority" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    `lean-rebac-core`'s `Rebac/core/NoGod.lean` (imported by `ReBAC.lean`)
    is a proven, coordinator-free gossip protocol for zone-range
    consensus: vector clocks (`VClock`), Hilbert-range containment
    (`ZoneRange`, `geometricAuthority`, `geometricInterest`), a hybrid
    logical clock (`HLC`), and theorems that gossip-based range adoption
    preserves `DisjointRanges` (no two zones ever claim overlapping
    authority) without a central coordinator.
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
