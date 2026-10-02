# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2230. `mix rfd.render` renders rfd/2230-ggml-adapters-in-godot-sandbox/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2230 do
  use RFD.DSL

  rfd 2230, "ggml model adapters as sandboxed GDScript over one native module" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `392beb7`.
    """

    drafted_by :ai
  end
end
