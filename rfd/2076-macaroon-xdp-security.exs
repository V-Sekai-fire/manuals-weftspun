# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2076. `mix rfd.render` renders rfd/2076-macaroon-xdp-security/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2076 do
  use RFD.DSL

  rfd 2076, "Macaroon xdp security" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    Directly validating a chained-HMAC Macaroon inside an XDP packet
    filter is impossible and undesirable:
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
