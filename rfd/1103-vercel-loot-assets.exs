# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1103. Abandoned by RFD 2285.
defmodule RFD1103 do
  use RFD.DSL

  rfd 1103, "Loot assets from a CDN, not a full clone, on Vercel" do
    state :abandoned

    feature "retracted"

    scope "retracted"

    decision ~S"""
    Retracted 2026-09-29 by RFD 2285.
    """

    drafted_by :ai
  end
end
