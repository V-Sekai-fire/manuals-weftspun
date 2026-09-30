# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2092. `mix rfd.render` renders rfd/2092-rebac-gates-libriscv-guest-access/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2092 do
  use RFD.DSL

  rfd 2092, "Rebac gates libriscv guest access" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    Discussion only. No implementation exists yet. Nothing today calls
    `check_expr`, `rebac_can_json`, or any `lean-rebac-core` predicate
    from a `libriscv` host callback.
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
