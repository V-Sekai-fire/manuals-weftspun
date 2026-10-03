# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2010, "Maglev cycle 1 gateway handshake", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  A minimal Godot client is more work than a curl or harness ping, and
  the work cannot be skipped: a non-Godot client would not catch
  Godot-specific datagram handling before it reaches a gameplay scene.
  :: related
  The full argument is in git at `a6eb679`.
  """
end
