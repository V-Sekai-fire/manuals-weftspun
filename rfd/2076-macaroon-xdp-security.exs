# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2076, "Macaroon xdp security", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  Directly validating a chained-HMAC Macaroon inside an XDP packet
  filter is impossible and undesirable:
  :: related
  The full argument is in git at `a6eb679`.
  """
end
