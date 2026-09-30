# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2116. `mix rfd.render` renders rfd/2116-elixir-epoll-zone-server-in-the-h2o-style/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2116 do
  use RFD.DSL

  rfd 2116, "Elixir epoll zone server in the h2o style" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    The cost is not the machine. `rfd/0102` costed the deployment at 15
    USD with the native server in it.
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
