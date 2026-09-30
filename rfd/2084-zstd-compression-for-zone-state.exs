# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2084. `mix rfd.render` renders rfd/2084-zstd-compression-for-zone-state/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2084 do
  use RFD.DSL

  rfd 2084, "Zstd compression for zone state" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    mas-bandwidth/fps assumes 10x bandwidth reduction via delta
    compression against a baseline (RFD 2002). zstd provides
    general-purpose compression that complements delta compression:
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
