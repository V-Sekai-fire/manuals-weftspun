# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2074. `mix rfd.render` renders rfd/2074-binary-value-encoding-for-fdb/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2074 do
  use RFD.DSL

  rfd 2074, "Binary value encoding for fdb" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    1. Zero-copy deserialization: a packed struct can be cast directly
    from FDB's `FDBKeyValue.value` pointer. No parsing step. The callback
    handler does `(stock_val_t *)kv->value` and reads fields.
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
