# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1074, "A caption label over each billboard card", :moved do
  preamble ~S"""
  Developed in its own repository,
  [weftspun/billboard-labels](https://github.com/weftspun/billboard-labels),
  per the user's own direction: a feature too large for one session,
  built where it can be reviewed as a pull request. Moves back to
  this directory once that PR lands.
  """

  attest_in :none
end
