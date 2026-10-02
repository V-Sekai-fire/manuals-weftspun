# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2067. `mix rfd.render` renders rfd/2067-release-tag-progression-dev-beta-rc/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2067 do
  use RFD.DSL

  rfd 2067, "Release tag progression dev beta rc" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `392beb7`.
    """

    drafted_by :ai
  end
end
