# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2077. `mix rfd.render` renders rfd/2077-pert-critical-path-zonefabric/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2077 do
  use RFD.DSL

  rfd 2077, "Pert critical path zonefabric" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    Expected duration (TE) for each task uses the PERT formula:
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
