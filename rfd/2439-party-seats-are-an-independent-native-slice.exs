# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2439, "party seats are an independent native slice", :discussion do
  flight_level :l1
  feature "a party of one player and three seats runs from a program that needs no campus."
  scope "the seats half of the party-and-shop beta feature as its own native program, its gates
  and its controls."

  prose ~S"""
  :: hook
  Can a seat's takeover be proven with no campus, no shop and no headset?
  :: intrigue
  The abandoned loop proved only bot players. A player may want to play the part an agent plays,
  and the takeover has never run.
  :: exit
  Run the takeover gate: after a player takes a seat, its actions come only from the player. An
  agent that keeps acting must fail it.
  :: decision
  - Seats ship as one native program: one player and three seats named Aria, Ember and Quill. A
    friend or an agent on the Agent2Agent protocol fills each seat (operator, 2026-11-01).
  - The program asks a seat for its action and takes the answer. A player takes a seat from its
    agent at any time, and the agent's later actions are ignored (operator, 2026-11-01).
  - The slice runs with no sight, voice, pen or shop present. Its inputs are scripted seat answers
    (operator, 2026-11-01).
  :: related
  - RFD66606-2358, the party; RFD66606-2360, the one beta.
  - The sibling slices are RFD66606-2436 to RFD66606-2438 and RFD66606-2440.
  """

  details_title "party seats are an independent native slice"

  prose ~S"""
  :: details What the beta asks
  One player and three seats, each filled by a friend or a persona, with the takeover.
  RFD66606-2358 decides the seats and the takeover, and this slice keeps that decision as written.

  :: details What exists
  Read from the repository descriptions in our organization, not from the code: an Agent2Agent
  v1.0 server in Lean 4 and a planning-domain persona live in repositories of their own. The seat
  slot, the takeover and the agent that fills a seat are new.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Loot contention: one grant and one committed row for four bot players. Control: a second grant
    planted.
  - Takeover: after a player takes a seat, the seat's actions come only from the player. Control:
    the agent still acting.
  - Alone: the program passes both gates with every sibling slice absent. Control: a sibling's
    message planted in the input.

  :: details Where the code lands
  Each slice is a repository of its own in our organization, named for what it does with no game
  name, and pinned through the repo manifest. It arrives as an ordinary pull request. V-Sekai
  repositories stay read-only.

  :: details What is not known
  - Whether native means a host binary or a guest ELF for the sandbox. The operator asked for
    native independent slices on 2026-11-01 and has not chosen. The first step builds the gate as
    a host binary, and the choice stays open.
  - What happens to a fight in progress when a player takes a seat. The first step decides it
    (RFD66606-2358).
  - Whether an agent answers the server's call for a seat fast enough, and how it behaves with
    three seats open at once. Nothing has run.
  :: details The problem
  RFD66606-2360 lists four features and names no way to build one without the others.
  """
end
