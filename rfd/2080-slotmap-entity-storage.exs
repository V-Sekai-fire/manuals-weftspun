# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2080. `mix rfd.render` renders rfd/2080-slotmap-entity-storage/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2080 do
  use RFD.DSL

  rfd 2080, "Slotmap entity storage" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    Zonefabric's ZoneTick iterates all 200 entities in a zone every tick.
    The iteration pattern is:
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
