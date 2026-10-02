# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2285. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2285-unship-the-web-demo-and-xr-paths/; the Markdown is a build artifact
# (RFD 2232).
defmodule RFD2285 do
  use RFD.DSL

  rfd 2285, "Unship the web demo and the XR paths" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `2c676e4`.
    """

    drafted_by :ai
  end
end
