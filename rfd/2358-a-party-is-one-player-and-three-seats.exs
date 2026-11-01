# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2358, "A party is one player and three seats", :discussion do
  flight_level :l1
  scope "the party of four, its seats, and the takeover."

  prose ~S"""
  :: hook
  A party is one player and three seats that a friend or an agent can fill.
  :: intrigue
  A player may want to play the part an agent plays, yet the abandoned RFD66606-2045 loop
  proved only bot players.
  :: exit
  Run the takeover gate: after a player takes a seat, its actions come only from the player.
  :: decision
  - The party is one player and three seats named Aria, Ember and Quill. A friend or an agent on
    the Agent2Agent protocol fills each seat, and a player takes a seat from its agent at any time
    (operator, 2026-10-30).
  :: related
  - RFD66606-2340, the campus; RFD66606-2359, the shop; RFD66606-2360, the one beta.
  - RFD66606-2045, the loop with bot players, is abandoned.
  """

  details_title "A party is one player and three seats"

  prose ~S"""
  :: details The party and its seats
  A party is four: one player and three seats. The seats are Aria, Ember and Quill, and a seat is
  the same slot whether a friend or an agent fills it. The server asks the seat for its action and
  takes the answer, so a person and an agent are interchangeable. When a player takes a seat, the
  agent's later actions are ignored and the player's are taken.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Loot contention: one grant and one committed row for four bot players. Control: a second
    grant planted.
  - Takeover: after a player takes a seat, the seat's actions come only from the player. Control:
    the agent still acting.

  :: details What is not known
  - What happens to a fight in progress when a player takes a seat. The first step decides it.
  - Whether an agent answers the server's call for a seat fast enough, and how it behaves with
    three seats open at once. Nothing has run.
  :: details The problem
  RFD66606-2045 proved a loop with bot players.
  """
end
