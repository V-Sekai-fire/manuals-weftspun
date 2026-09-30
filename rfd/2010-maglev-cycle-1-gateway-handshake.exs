# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2010. `mix rfd.render` renders rfd/2010-maglev-cycle-1-gateway-handshake/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2010 do
  use RFD.DSL

  rfd 2010, "Maglev cycle 1 gateway handshake" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    A minimal Godot client is more work than a curl or harness ping, and
    the work cannot be skipped: a non-Godot client would not catch
    Godot-specific datagram handling before it reaches a gameplay scene.
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
