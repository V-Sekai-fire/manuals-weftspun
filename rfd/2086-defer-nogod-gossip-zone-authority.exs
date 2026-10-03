# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2086, "Defer nogod gossip zone authority", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  `lean-rebac-core`'s `Rebac/core/NoGod.lean` (imported by `ReBAC.lean`)
  is a proven, coordinator-free gossip protocol for zone-range
  consensus: vector clocks (`VClock`), Hilbert-range containment
  (`ZoneRange`, `geometricAuthority`, `geometricInterest`), a hybrid
  logical clock (`HLC`), and theorems that gossip-based range adoption
  preserves `DisjointRanges` (no two zones ever claim overlapping
  authority) without a central coordinator.
  :: related
  The full argument is in git at `a6eb679`.
  """
end
