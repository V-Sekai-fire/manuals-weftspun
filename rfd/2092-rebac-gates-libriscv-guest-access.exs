# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2092, "Rebac gates libriscv guest access", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  Discussion only. No implementation exists yet. Nothing today calls
  `check_expr`, `rebac_can_json`, or any `lean-rebac-core` predicate
  from a `libriscv` host callback.
  :: related
  The full argument is in git at `a6eb679`.
  """
end
