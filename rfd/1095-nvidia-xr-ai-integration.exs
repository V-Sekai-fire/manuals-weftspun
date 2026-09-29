# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1095. Abandoned by RFD 2285.
defmodule RFD1095 do
  use RFD.DSL

  rfd 1095, "A voice XR path, beside Task Manager, same backend" do
    state :abandoned

    feature "retracted"

    scope "retracted"

    decision ~S"""
    Retracted 2026-09-29 by RFD 2285.
    """

    drafted_by :ai
  end
end
