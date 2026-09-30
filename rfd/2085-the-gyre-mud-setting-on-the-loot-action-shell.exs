# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2085. `mix rfd.render` renders rfd/2085-the-gyre-mud-setting-on-the-loot-action-shell/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2085 do
  use RFD.DSL

  rfd 2085, "The gyre mud setting on the loot action shell" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    `rfd/2045-loot-action-core-loop-mvp-vertical-slice` shipped a playable
    shell: a Hub where players gather, an instanced Field room for one
    loot-action loop, and five hexagonal cores (Combat, Loot, Presence,
    Progression, Budgeter) behind ports. That slice targets SteamVR, one
    melee combo, one loot drop, four players.
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
