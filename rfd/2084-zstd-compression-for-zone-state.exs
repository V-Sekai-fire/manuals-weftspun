# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2084, "Zstd compression for zone state", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  mas-bandwidth/fps assumes 10x bandwidth reduction via delta
  compression against a baseline (RFD 2002). zstd provides
  general-purpose compression that complements delta compression:
  :: related
  The full argument is in git at `a6eb679`.
  """
end
