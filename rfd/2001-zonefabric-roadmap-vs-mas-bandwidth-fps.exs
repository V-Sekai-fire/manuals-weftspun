# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2001. `mix rfd.render` renders
# rfd/2001-zonefabric-roadmap-vs-mas-bandwidth-fps/README.md and DETAILS.md from
# this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2001 do
  use RFD.DSL

  rfd 2001, "Zonefabric roadmap vs mas bandwidth fps" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `392beb7`.
    """

    drafted_by :ai
  end
end
