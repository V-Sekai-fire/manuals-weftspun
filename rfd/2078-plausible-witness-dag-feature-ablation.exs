# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2078. `mix rfd.render` renders rfd/2078-plausible-witness-dag-feature-ablation/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2078 do
  use RFD.DSL

  rfd 2078, "Plausible witness dag feature ablation" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    Building an MMO is expensive. Every feature is a bet:
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
