# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2297. `mix rfd.render` renders
# rfd/2297-the-first-rungs-dev-3/README.md and DETAILS.md from
# this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2297 do
  use RFD.DSL

  rfd 2297, "the first rung's dev.3" do
    state :discussion

    flight_level :l1

    feature "the dev rung that follows dev.2 on RFD 2293's release ladder"

    scope "the pen's `v<date>-dev.3` release"

    decision ~S"""
    dev.3 ships each platform's game as one executable with its `.pck`
    embedded, exported at double precision.
    """

    problem ~S"""
    dev.1 and dev.2 shipped the double editor, the addon and the guest
    ELFs, so a player needs a pen checkout to open them.
    """

    related ~S"""
    - RFD 2293, the workspace, the ladder and dev.1; its release rules hold here.
    - RFD 2296, dev.2; RFD 2297, dev.3; RFD 2298, dev.next.
    """

    drafted_by :ai

    details_title "the first rung's dev.3"

    details "dev.3: one executable per platform with its pack inside", ~S"""
    Operator, 2026-10-03.

    The release carries each platform's game as one executable with its
    `.pck` embedded, exported at double precision. dev.2 shipped the double
    editor, the addon and the guest ELFs for a checkout to open instead.
    """

  end
end
