# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2014. `mix rfd.render` renders rfd/2014-art-game-loop-steel-thread/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2014 do
  use RFD.DSL

  rfd 2014, "Art game loop steel thread" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    We want a small workspace where friends make tiny art-games together,
    watch them, and improve them on a tight loop. Players show up in the
    space as tracker orbs (the presence demo), with drawing pens (cassie)
    as a stretch goal. Before building the workspace out, we need the
    smallest end-to-end thread that proves the loop runs at all. What is
    that thread?
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
