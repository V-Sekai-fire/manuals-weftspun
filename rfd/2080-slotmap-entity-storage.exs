# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2080, "Slotmap entity storage", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  Zonefabric's ZoneTick iterates all 200 entities in a zone every tick.
  The iteration pattern is:
  :: related
  The full argument is in git at `a6eb679`.
  """
end
