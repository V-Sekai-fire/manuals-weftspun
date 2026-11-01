# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2436, "presence is an independent native slice", :discussion do
  flight_level :l1
  feature "two people in one campus zone see each other's avatars from a program that runs alone."
  scope "the see-each-other beta feature as its own native program, its gate and its control."

  prose ~S"""
  :: hook
  Can two people see each other from a program that needs nothing else in the beta?
  :: intrigue
  The beta lists seeing each other first, and nothing built yet carries it alone. A slice that
  needs voice, the pen and the party to run depends on all three.
  :: exit
  Run the sight gate against a recorded pose stream. A zone that drops one side's poses must fail
  it.
  :: decision
  - Presence ships as one native program with no editor or browser. It owns the
    zone's list of people and their avatar poses (operator, 2026-11-01).
  - The slice runs with no voice, pen, party or shop present. Its inputs are recorded pose streams
    in place of those parts (operator, 2026-11-01).
  - Native means a riscv64 guest ELF for the sandbox, run binary-translated (operator,
    2026-11-01). Its gates run on the CPU guest as the parity oracle (RFD66606-2374,
    RFD66606-2390).
  :: related
  - RFD66606-2360, the one beta; RFD66606-2340, the campus.
  - The sibling slices are RFD66606-2437 to RFD66606-2440.
  """

  details_title "presence is an independent native slice"

  prose ~S"""
  :: details What the beta asks
  The beta's first feature is two people in the campus zone, one in the Steam Frame on a PC VR
  stream and one on the desktop. Each sees the other's avatar. The slice holds that and nothing
  more: who is in the zone, where each avatar stands, and the pose each person sends.

  :: details The slice's edge
  In: the zone's list of people, a pose from each, and a view of the others for each person. Out:
  voice, outfits, seats and books, which are the sibling slices. The edge is a message shape
  between the zone and a client. It is the only contract the slice shares, and its first step
  writes it down.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Sight: two clients replay a pose stream, and each client's view lists the other's avatar at
    the replayed pose. Control: a zone that drops one client's poses.
  - Alone: the program starts and passes its sight gate with every sibling slice absent. Control:
    a sibling's message planted in the input, which the program must refuse by name.

  :: details Where the code lands
  Each slice is a repository of its own in our organization, named for what it does with no game
  name, and pinned through the repo manifest. It arrives as an ordinary pull request. V-Sekai
  repositories stay read-only.

  :: details What is not known
  - Which pose message shape the PC VR stream and the desktop client both send. The first step
    reads it from the clients and writes it down.
  - Whether a zone holds the pose rate for two people. Nothing has run, and no number is claimed.
  :: details The problem
  RFD66606-2360 lists four features and names no way to build one without the others.
  """
end
