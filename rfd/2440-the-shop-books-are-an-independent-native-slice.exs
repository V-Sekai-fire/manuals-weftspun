# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2440, "the shop books are an independent native slice", :discussion do
  flight_level :l1
  feature "the shopkeeper keeps a saved world for each conversation, from one program."
  scope "the shop half of the party-and-shop beta feature as its own native program, its gate and
  its control."

  prose ~S"""
  :: hook
  Does a shopkeeper that has met a request answer the second one with nothing left to do?
  :: intrigue
  The loop the campus replaces named a store this workspace has retired. A store that forgets
  every write answers the second request as if it were the first.
  :: exit
  Run the memory gate: the second request for a goal in one conversation returns an empty plan. A
  store that forgets every write must fail it.
  :: decision
  - The shop ships as one native program: the shopkeeper persona with its saved world for each
    conversation, kept in SQLite on FoundationDB through a secrets engine that runs named
    statements (operator, 2026-11-01).
  - The slice runs with no sight, voice, pen or seats present. Its inputs are scripted requests
    (operator, 2026-11-01).
  - Native means a riscv64 guest ELF for the sandbox, run binary-translated (operator,
    2026-11-01). Its gates run on the CPU guest as the parity oracle (RFD66606-2374,
    RFD66606-2390).
  :: related
  - RFD66606-2359, the shopkeeper; RFD66606-2339, the persona; RFD66606-2360, the one beta.
  - The sibling slices are RFD66606-2436 to RFD66606-2439.
  """

  details_title "the shop books are an independent native slice"

  prose ~S"""
  :: details What the beta asks
  The shopkeeper persona and its saved world, so a request it has met is answered with nothing
  left to do. RFD66606-2359 decides the books, and this slice keeps that decision as written.

  :: details What exists
  Read from the repository descriptions in our organization, not from the code: a planning-domain
  persona, and a secrets engine that runs precanned SQL against SQLite on the fabric's store, live
  in repositories of their own. The shop's wiring of the two is new.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Memory: the second request for a goal in one conversation returns an empty plan that has
    reached it. Control: a store that forgets every write.
  - Alone: the program passes its gate with every sibling slice absent. Control: a sibling's
    message planted in the input.

  :: details Where the code lands
  Each slice is a repository of its own in our organization, named for what it does with no game
  name, and pinned through the repo manifest. It arrives as an ordinary pull request. V-Sekai
  repositories stay read-only.

  :: details What is not known
  - Whether many instances of one campus each keep a separate books database. One database for
    each instance is possible, and no run has opened more than one (RFD66606-2359).
  :: details The problem
  RFD66606-2360 lists four features and names no way to build one without the others.
  """
end
