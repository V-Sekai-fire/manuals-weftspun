# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2340, "a campus where a party of four draws and wears", :discussion do
  flight_level :l1
  feature "students draw outfits with the pen and wear them in a shared campus zone, and a
party of four walks from the campus shop to a room and back"
  scope "the campus zone, the pen's first rung, and where the code lands"

  prose ~S"""
  :: decision
  **The first playable is a campus where students draw outfits and wear them.**

  - The first playable is a college campus: college-age students draw outfits with the pen and
    wear them in a shared zone, and a party of four walks from the campus shop to a room and
    back (operator, 2026-10-30).
  - The pen comes first: its first rung (RFD66606-2287, draw and wear in a headset) runs in the
    campus zone before the party loop is built (operator, 2026-10-30).
  - RFD66606-2045 (loot-action slice) is abandoned. This RFD keeps its loop of hub, room, first
    touch and return, and replaces its party and its store (operator, 2026-10-30).

  The party is RFD66606-2358, the shopkeeper is RFD66606-2359, and the beta is RFD66606-2360.
  Run the pen's gates in the campus zone first.
  :: problem
  The pen's first rung proves two people see a drawn outfit, and it has no campus to wear it in.
  RFD66606-2045 has no setting a person returns to.
  :: related
  - RFD66606-2287, the pen; RFD66606-2339, the persona; RFD66606-2321, the autobattler.
  - RFD66606-2358, the party; RFD66606-2359, the shop; RFD66606-2360, the one beta.
  - Abandons RFD66606-2045, which RFD66606-2057 and RFD66606-2069 cite.
  """

  details_title "a campus where a party of four draws and wears"

  prose ~S"""
  :: details Sources
  Drafted on 2026-10-30 from the loot-action slice as written, the pen's first rung, the persona
  RFD, the autobattler RFD, the descriptions of the auto-rig viewer and the V-Sekai proposals on
  the campus and the princess, and the operator's requests of the same day.

  :: details What exists
  Each part is marked as it is read from its own source, not from this RFD.

  - Wired: the loop of hub, room, first touch and return. A server and four bot players ran it
    once, granted exactly one bot and committed exactly one profile row (loot-action slice,
    2026-06-29). Persistence there is SQLite on the server's disk.
  - Wired: the pen. Its repository holds the guest programs for fitting, curve drawing, dress-on,
    physics, USD and the worker, and RFD66606-2287 decides how a person draws and wears an outfit.
  - Wired: the persona answers a goal with an exact plan or a refusal by name (RFD66606-2339).
  - Written, not landed: a saved world for each persona conversation. A library keeps it behind a
    store interface, and a gate checks it against a store that forgets every write.
  - Wired: a viewer rigs an uploaded model on the GPU and saves the rig as a VRM file when it has
    a person's shape.
  - Wired: the autobattler builds its fighters from solids a guest kernel makes (RFD66606-2321).
  - New: the campus zone, the seats, the takeover, and an agent that fills a seat.

  :: details The campus
  A campus is a world, and a world runs as instances. Any player starts an instance for friends,
  public or invite-only. One zone server is the authority for one instance, as the loot-action
  slice decided. Each instance keeps its own shop books. One campus ships first; building a campus
  stays with the V-Sekai content tools.

  :: details The pen in the campus
  The first rung stays as RFD66606-2287 decides it: a person in a headset draws an outfit, a
  worker zone makes the garment, its ghost appears in the campus zone, and ownership hands over to
  that zone. The campus adds the place and the people: students in the same hall see the outfit
  and talk. Whether an agent in a seat can wear a drawn outfit is not decided.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Pen: the gates of RFD66606-2287, unchanged.

  :: details Where the code lands
  Every repository change lands in our own organizations. The persona, the protocol library and
  the zone work arrive as ordinary pull requests in their own repositories, and V-Sekai
  repositories stay read-only.

  :: details What is not known
  - Whether the pen's outfits and the rigged models reach the campus unchanged. Each part is read
    for its precision and format before the campus uses it.
  """
end
