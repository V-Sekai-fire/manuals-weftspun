# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2004. `mix rfd.render` renders rfd/2004-castspell-libgodot-sandbox-runtime-scope/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2004 do
  use RFD.DSL

  rfd 2004, "Castspell libgodot sandbox runtime scope" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    `rfd/2001-zonefabric-roadmap-vs-mas-bandwidth-fps/index.md`, item 6,
    commits to scoping how much of `libriscv`/`godot-sandbox`'s API
    surface CastSpell effects actually need. This RFD is the detail that
    item pointed to. It resolves the scoping question and decides to embed
    a real, headless `libgodot` instance per zone instead of
    reimplementing `godot-sandbox`'s narrow API. It also records a real
    spike that proved the approach boots correctly.
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
