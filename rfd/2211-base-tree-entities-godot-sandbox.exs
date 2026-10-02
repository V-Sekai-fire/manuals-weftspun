# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2211. `mix rfd.render` renders rfd/2211-base-tree-entities-godot-sandbox/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2211 do
  use RFD.DSL

  rfd 2211, "base tree: `entities-godot-sandbox` for the atelier" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `392beb7`.
    """

    drafted_by :ai
  end
end
