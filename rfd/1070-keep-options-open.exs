# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1070, "Keep options open", :published do
  scope "`decisions/`"
  attest_in :none

  prose ~S"""
  :: hook
  Wait for a commitment before opening an RFD; waiting holds an asset.
  :: intrigue
  This repository wrote down three RFDs for a build nobody started.
  :: exit
  Read `DETAILS.md` for the three RFDs this rule removed and what it left in place.
  :: decision
  Do not open an RFD for a build this project has not committed to.

  Kent Beck's price-theory reading of YAGNI names the cost: an
  unexercised option costs twice if the guess is wrong, so a thing not
  yet committed to is worth more left unbuilt. Waiting holds an asset.
  It does not delay work.

  The rule stops a new RFD from opening before commitment. It does not
  reach back into one already running.
  :: problem
  Each carried a reading cost, a cross-reference to keep current, and
  an index row, for an option nobody had exercised.
  :: references
  - Kent Beck, "The Cost YAGNI Was Never About":
    https://newsletter.kentbeck.com/p/the-cost-yagni-was-never-about
  :: related
  RFD66606-1000 gives the state ladder a speculative RFD would otherwise
  sit on. RFD66606-1031 keeps the fallback RFD66606-1032 would have replaced.
  """

  details_title "Keep options open"

  prose ~S"""
  :: details What each one was
  RFD66606-1024 picked nx-ggml, and RFD66606-1019 replaced it, yet RFD66606-1024
  stayed in the index as a live decision. RFD66606-1032 sketched a
  clean-room alpha wrap algorithm RFD66606-1031's fallback already made
  unneeded. RFD66606-1068 picked a training approach for a model that needs
  data RFD66606-1064 has not finished producing.
  :: details What the rule left in place
  This session deleted RFD66606-1024, RFD66606-1032, and RFD66606-1068 under this
  rule. RFD66606-1031 keeps its existing fallback, with no successor RFD
  promised.

  Committed work already under way, such as RFD66606-1064 and RFD66606-1065, is
  not this rule's target.
  :: details The register of deleted numbers
  A later session deleted RFD66606-1069, RFD66606-1071, and RFD66606-1072 under this
  rule. RFD66606-1064 records the bar each one failed.

  A deleted number is not reused, and the RFDs above still cite it.
  Deleting a directory does not delete a citation. `SERIALS.usda` keeps a
  row for each of the six, and RFD66606-1124's gate reads that file when it
  checks that a citation resolves. RFD66606-1000 gives the register's rule.
  """
end
