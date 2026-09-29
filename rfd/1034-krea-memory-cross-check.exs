# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1034. `mix rfd.render` renders rfd/1034-krea-memory-cross-check/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD1034 do
  use RFD.DSL

  rfd 1034, "Krea memory cross-check" do
    state :abandoned

    feature "capacity planning"

    attest_in :none

    decision ~S"""
    Check the rule against the one model with a measured number. Krea 2
    Turbo is that model. `scripts-cheatsheet.md` records 57 GB on disk,
    and a 32 GB reserve per worker.

    See `DETAILS.md` for the parameter estimate by part, and how it
    compares against the measured reserve and disk size.
    """

    problem ~S"""
    RFD 1025 gives a rule for the memory. RFD 1026 applies that rule to
    models with no published parameter count. An unchecked rule on an
    estimated count gives two errors, and not one.
    """

    related ~S"""
    RFD 1025 gives the rule. RFD 1026 gives the counts this check cannot
    confirm.
    """

    drafted_by :ai
  end
end
