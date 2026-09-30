# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2108. `mix rfd.render` renders rfd/2108-local-cabi-guests-and-in-tick-fanout/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2108 do
  use RFD.DSL

  rfd 2108, "Local cabi guests and in tick fanout" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    Every number comes from `rfd/0097` and `rfd/0096`. One ZoneTick at 64
    Hz is 15.6 ms.
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
