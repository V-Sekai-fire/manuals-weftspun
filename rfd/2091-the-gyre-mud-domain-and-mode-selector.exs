# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2091. `mix rfd.render` renders rfd/2091-the-gyre-mud-domain-and-mode-selector/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2091 do
  use RFD.DSL

  rfd 2091, "The gyre mud domain and mode selector" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    Done for the smallest loop (`zone-server-h2o` PR #5). Not verified end
    to end.
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
