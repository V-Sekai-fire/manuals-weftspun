# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2002. `mix rfd.render` renders rfd/2002-taskweft-value-narrowing-primitives-and-refs/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2002 do
  use RFD.DSL

  rfd 2002, "Taskweft value narrowing primitives and refs" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    `taskweft/nif` (the C++ core behind the `taskweft/taskweft` Elixir
    host, a separate repo from the one the name suggests) narrows every
    value that crosses an interpreter or ABI boundary down to one small
    tagged union, `TwValue`, with seven kinds: `NIL`, `BOOL`, `INT`,
    `FLOAT`, `STRING`, `ARRAY`, `DICT`. There is no eighth kind for
    references. A reference is a plain `STRING` value, shaped as an RFC
    6901 JSON Pointer, resolved against a flat `var -> Dict` state tree at
    the point of use. This RFD records that real design, checked directly
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
