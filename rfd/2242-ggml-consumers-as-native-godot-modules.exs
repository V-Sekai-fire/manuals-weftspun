# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2242. `mix rfd.render` renders rfd/2242-ggml-consumers-as-native-godot-modules/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2242 do
  use RFD.DSL

  rfd 2242, "ggml consumers as native Godot modules stacked on modules/ggml" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `392beb7`.
    """

    drafted_by :ai
  end
end
