# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2075. `mix rfd.render` renders rfd/2075-fdb-over-cockroachdb-for-zone-state/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2075 do
  use RFD.DSL

  rfd 2075, "Fdb over cockroachdb for zone state" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `392beb7`.
    """

    drafted_by :ai
  end
end
