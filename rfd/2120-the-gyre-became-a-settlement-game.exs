# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2120. `mix rfd.render` renders rfd/2120-the-gyre-became-a-settlement-game/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2120 do
  use RFD.DSL

  rfd 2120, "The gyre became a settlement game" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    | | RFD 2085 | `service-store` | | ---------- |
    --------------------------------- |
    ----------------------------------------------- | | The player | A
    Spark taking contracts | The Queen, commissioning venues | | The loop
    | Hub, field, return | Commission, then wait a cycle | | The map | Six
    zones to travel | Six venues on two decks | | Contracts | Taken by the
    player | Chosen by Sparks, resolved against risk | | Currency | Chits
    | Scrip | | Antagonist | Overseer Q-11 | The Debt Clock, compounding
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
