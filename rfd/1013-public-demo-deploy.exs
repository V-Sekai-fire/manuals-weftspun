# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1013. Abandoned by RFD 2285.
defmodule RFD1013 do
  use RFD.DSL

  rfd 1013, "Public demo deploy" do
    state :abandoned

    feature "retracted"

    scope "retracted"

    decision ~S"""
    Retracted 2026-09-29 by RFD 2285.
    """

    drafted_by :ai
  end
end
