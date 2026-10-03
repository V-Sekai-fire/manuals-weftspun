# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2074, "Binary value encoding for fdb", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  1. Zero-copy deserialization: a packed struct can be cast directly
  from FDB's `FDBKeyValue.value` pointer. No parsing step. The callback
  handler does `(stock_val_t *)kv->value` and reads fields.
  :: related
  The full argument is in git at `a6eb679`.
  """
end
