# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2066. `mix rfd.render` renders rfd/2066-game-loop-cluster-sequence/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2066 do
  use RFD.DSL

  rfd 2066, "Game loop cluster sequence" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    The team polled on which concern to stabilise next. Game-loop received
    2 of 4 votes (50%). The uiux-polish, cassie-pen-mesh, shop-economy,
    and openUSD-i/o concerns all require a verified game-loop as their
    integration target and are not testable end-to-end without one.
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
