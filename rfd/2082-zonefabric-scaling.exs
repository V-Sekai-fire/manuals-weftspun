# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2082. `mix rfd.render` renders rfd/2082-zonefabric-scaling/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2082 do
  use RFD.DSL

  rfd 2082, "Zonefabric scaling" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    **Scale knob:** zone count (direct, no multiplier) **Source:**
    weftspun/scenario-tpcc-bench PR #2
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
