# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2437, "voice is an independent native slice", :discussion do
  flight_level :l1

  feature "two people in one campus zone hear each other at the speaker's avatar, from one."

  scope "the hear-each-other beta feature as its own native program, its gate and its control."

  prose ~S"""
  :: hook
  Where should a listener hear a speaker, and can that be proven without a headset?
  :: intrigue
  The beta says voice is played at the speaker's avatar. A program that plays it at the listener's
  own head also carries voice, and the beta would not catch it.
  :: exit
  Run the placement gate on recorded frames and a fixed pair of avatar positions. A player that
  ignores the speaker's position must fail it.
  :: decision
  - Voice ships as one native program with no editor or browser. It carries
    voice frames from a speaker to a listener and places them at the speaker's avatar (operator,
    2026-11-01).
  - The slice runs with no sight, pen, party or shop present. Its inputs are recorded voice frames
    and fixed avatar positions (operator, 2026-11-01).
  - Native means a riscv64 guest ELF for the sandbox, run binary-translated (operator,
    2026-11-01). Its gates run on the CPU guest as the parity oracle (RFD66606-2374,
    RFD66606-2390).
  :: related
  - RFD66606-2360, the one beta; RFD66606-2340, the campus.
  - The sibling slices are RFD66606-2436, RFD66606-2438, RFD66606-2439 and RFD66606-2440.
  """

  details_title "voice is an independent native slice"

  prose ~S"""
  :: details What the beta asks
  Voice between the two people, played at the speaker's avatar. The slice holds the voice path
  from one person to the other and the placement of the sound. It holds no avatar and no zone
  list: it takes a position as an input.

  :: details The slice's edge
  In: voice frames and the speaker's position and the listener's position. Out: audio placed at
  the speaker. No codec is chosen for the frames. The position input is the same
  message shape the presence slice owns, so the first step reads that shape instead of inventing
  one.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Placement: the sound's source position equals the speaker's avatar position, and the
    listener's position changes only the pan and the level. Control: a player that places the
    sound at the listener.
  - Delivery: every recorded frame reaches the listener in order. Control: a path that drops every
    tenth frame.
  - Alone: the program passes both gates with every sibling slice absent. Control: a sibling's
    message planted in the input.

  :: details Where the code lands
  Each slice is a repository of its own in our organization, named for what it does with no game
  name, and pinned through the repo manifest. It arrives as an ordinary pull request. V-Sekai
  repositories stay read-only.

  :: details What is not known
  - Which codec and frame size carry the voice. The first step names the candidates and what each
    costs.
  - Whether the Steam Frame's stream and the desktop client share one capture path. Nothing has
    run.
  :: details The problem
  RFD66606-2360 lists four features and names no way to build one without the others.
  """
end
