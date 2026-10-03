# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2098, "rollback snapshot budget", :discussion do
  scope "the apparatus in this directory"

  prose ~S"""
  :: decision
  None recorded. The serial was allocated and the apparatus (`rollback.cpp`) was written; the
  document was not. The serial stays allocated, as RFD 1000 says a serial never moves once
  issued.
  :: problem
  A directory with code and no README reads as a document that was deleted rather than one that
  was never written. This page names which it is.
  """
end
