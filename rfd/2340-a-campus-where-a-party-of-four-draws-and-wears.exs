# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2340, "a campus where a party of four draws and wears", :discussion do
  flight_level :l1
  feature "students draw outfits with the pen and wear them in a shared campus zone, and a
party of four walks from the campus shop to a room and back"
  scope "the campus zone, its shop, the party seats, the pen's first rung, and the persona
that keeps the books"

  prose ~S"""
  :: decision
  - The first playable is a college campus: college-age students draw outfits with the pen and
    wear them in a shared zone, and a party of four walks from the campus shop to a room and
    back (operator, 2026-10-30).
  - The pen comes first: its first rung (RFD66606-2287, draw and wear in a headset) runs in the
    campus zone before the party loop is built (operator, 2026-10-30).
  - The party is one player and three seats named Aria, Ember and Quill. A friend or an agent on
    the Agent2Agent protocol fills each seat, and a player takes a seat from its agent at any time
    (operator, 2026-10-30).
  - RFD66606-2045 (loot-action slice) is abandoned. This RFD keeps its loop of hub, room, first
    touch and return, and replaces its party and its store (operator, 2026-10-30).
  - The shopkeeper is a persona (RFD66606-2339, planning-domain persona) that keeps a saved world
    for each conversation in SQLite on FoundationDB (operator, 2026-10-30).
  :: problem
  RFD66606-2045 proved a loop with bot players, names a store this workspace has retired, and
  has no setting a person returns to. The pen's first rung proves two people see a drawn outfit,
  and it has no campus to wear it in.
  :: related
  - RFD66606-2287, the pen's first rung; RFD66606-2339, the persona; RFD66606-2321, the
    autobattler.
  - Abandons RFD66606-2045. RFD66606-2057 (repository map) and RFD66606-2069 (defer
    hardening) cite it.
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

  :: details The party and its seats
  A party is four: one player and three seats. The seats are Aria, Ember and Quill, and a seat is
  the same slot whether a friend or an agent fills it. The server asks the seat for its action and
  takes the answer, so a person and an agent are interchangeable. When a player takes a seat, the
  agent's later actions are ignored and the player's are taken.

  :: details The shop
  The shop shows what the winner took home. The shopkeeper is a persona with a saved world for
  each conversation, so a request it has already satisfied is answered with nothing left to do.
  The books are saved through a secrets engine that runs named statements against SQLite on
  FoundationDB, one database for each instance. This replaces the retired store the loot-action
  slice named.

  :: details Cut from the first playable
  The following stay out of the first playable (operator, 2026-10-30): a hidden director that
  plans the day, friendships and romance, a shared limit gauge with a team finisher, shop prices
  and a loan, an end-of-day report, a job board where each seat accepts or refuses a job, and
  campuses built by players.

  :: details Gates and controls
  Each gate has a control that plants the defect and must fail.

  - Loot contention: one grant and one committed row for four bot players. Control: a second
    grant planted.
  - Takeover: after a player takes a seat, the seat's actions come only from the player. Control:
    the agent still acting.
  - Memory: the second request for a goal in one conversation returns an empty plan that has
    reached it. Control: a store that forgets every write.
  - Pen: the gates of RFD66606-2287, unchanged.

  :: details Where the code lands
  Every repository change lands in our own organizations. The persona, the protocol library and
  the zone work arrive as ordinary pull requests in their own repositories, and V-Sekai
  repositories stay read-only.

  :: details What is not known
  - What happens to a fight in progress when a player takes a seat. The first step decides it.
  - Whether an agent answers the server's call for a seat fast enough, and how it behaves with
    three seats open at once. Nothing has run.
  - Whether many instances of one campus each keep a separate books database. One database for
    each instance is possible, and no run has opened more than one.
  - Whether the pen's outfits and the rigged models reach the campus unchanged. Each part is read
    for its precision and format before the campus uses it.
  """
end
