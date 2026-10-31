# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2359, "The shopkeeper keeps the books for each conversation", :discussion do
  flight_level :l1
  scope "the campus shop, its persona, and the books."

  prose ~S"""
  :: hook
  The shopkeeper keeps the books for each conversation, so a met request needs no more.
  :: intrigue
  RFD66606-2045 names a store this workspace has retired.
  :: exit
  Run the memory gate: the second request for a goal in one conversation returns an empty plan.
  :: decision
  - The shopkeeper is a persona (RFD66606-2339, planning-domain persona) that keeps a saved world
    for each conversation in SQLite on FoundationDB (operator, 2026-10-30).
  :: related
  - RFD66606-2339, the persona; RFD66606-2340, the campus; RFD66606-2358, the party.
  """

  details_title "The shopkeeper keeps the books for each conversation"

  prose ~S"""
  :: details The shop
  The shop shows what the winner took home. The shopkeeper is a persona with a saved world for
  each conversation, so a request it has already satisfied is answered with nothing left to do.
  The books are saved through a secrets engine that runs named statements against SQLite on
  FoundationDB, one database for each instance. This replaces the retired store the loot-action
  slice named.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Memory: the second request for a goal in one conversation returns an empty plan that has
    reached it. Control: a store that forgets every write.

  :: details What is not known
  - Whether many instances of one campus each keep a separate books database. One database for
    each instance is possible, and no run has opened more than one.
  """
end
