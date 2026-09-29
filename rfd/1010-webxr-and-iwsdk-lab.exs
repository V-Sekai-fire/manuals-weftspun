# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1010. Abandoned by RFD 2285.
defmodule RFD1010 do
  use RFD.DSL

  rfd 1010, "WebXR and IWSDK lab" do
    state :abandoned

    feature "retracted"

    scope "retracted"

    decision ~S"""
    Retracted 2026-09-29 by RFD 2285.
    """

    drafted_by :ai
  end
end
