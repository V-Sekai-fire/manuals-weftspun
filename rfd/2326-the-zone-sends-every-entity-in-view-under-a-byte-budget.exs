# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2326, "the zone sends every entity in view under a byte budget", :discussion do
  feature "a zone sends each player every simulated entity it can see, in the Lean entity
packet, at a rate set by a per-player byte budget rather than a fixed slice"
  scope "the fabric zone's publish path and its wire constants, and the entity packet spec"

  prose ~S"""
  :: decision
  The zoned server simulates every entity a player can see and sends each one
  as itself: its own id, position and velocity. No far entity becomes a crowd
  stand-in (operator, 2026-10-19). Distance changes only how often an entity's
  row reaches a player. A byte budget per player, filled nearest and most
  stale first, replaces the 64-row slice, so a player's cost stays fixed while
  everything in view stays real. The headset moves an entity along its sent
  velocity between rows, and the next row corrects it.

  The Lean entity packet spec is the one source of the wire row, and the zone
  writes the layout it emits. Five constants change; the details list each
  with its check and its planted defect.
  :: problem
  The zone sends every active entity to every player each tick, in a layout
  the spec does not describe: f64 positions, acceleration and a 56-byte
  payload at offset 44, where the spec has micrometre integers, rotation and
  42 bytes at offset 58. The logbook's measured 0.349 Mbit/s a player came
  from a bench with a 64-row cap and zstd that the zone does not have. A
  busy street puts thousands of people in view, and 64 rows cannot carry them.
  :: related
  - RFD 2287, the first rung: the zone and transport this changes.
  - RFD 2321, the autobattler as a zone: the first game on this path.
  """

  details_title "the budget, the five constants and their checks"

  prose ~S"""
  :: details Sources
  Drafted on 2026-10-19 from the zone repository's main branch, the entity
  packet spec, the abyssal zone's client, and the infrastructure logbook's
  topology, scaling, one-core and curves entries. A second agent reviewed the
  constants without the first draft's conclusions, and its findings that
  touch the code were checked against the source before they were kept.

  :: details The budget
  Each player has a byte budget per second. Every entity in the player's
  interest set has a priority that grows with the time since its last row and
  shrinks with its distance, as the logbook's curves entry describes. Each
  tick the zone sends the highest-priority rows until the tick's share of the
  budget is spent. The nearest entities, about sixteen, go every tick; the
  rest of the near band goes at about 20 Hz; far entities go down to about
  1 Hz. The budget starts at the logbook's 0.349 Mbit/s, and rows are deltas
  against the last row the player acknowledged, compressed with zstd.

  On traffic generated for the test (64 walkers at 5 km/h in the spec's
  packet, which flatter prediction and are why zombies are blocklisted as
  test traffic), absolute rows compressed 4.3 times and deltas against the previous
  row 8.6 times, about 11 bytes a row. A trained zstd dictionary added nothing
  at 6.4 kB messages. At 11 bytes, 2000 entities in view with the near band
  at 20 Hz and the rest at 2 Hz is about 0.45 Mbit/s. Recorded zone traffic
  with loss replaces both figures before the budget is fixed.

  :: details What a player can see
  The busiest street measured, a 53-minute walk at blue hour, held at most 16
  people that RF-DETR keypoints found at 1280 pixels wide, and about 40 by
  eye in the busiest frame. A tiled count at full resolution sets the real
  maximum; the budget is sized to that maximum with a buffer, and a crowd
  scene is sized on top.

  :: details The five constants
  - Publish rate. Today every tick to every player. Change to the budget
    above. Check: a player's bytes per second stay under the budget at 100,
    1000 and 5000 entities in view. Planted defect: the budget ignored.
  - Velocity scale. 500000 micrometres a tick is 36 km/h at the 20 Hz the
    predictive BVH derived it for, and 108 km/h at the zone's 60 Hz. Change
    to 115 km/h, stated per second, so hands and thrown props fit. Check: a
    112 km/h row round-trips; planted defect: the scale read per tick.
  - Clock counter. The zone adds one to an 8-bit counter per row, so it wraps
    after 256 rows in a tick. Change to one clock value per message. Check:
    1800 rows in one tick never decrease. Planted defect: the counter per row.
  - Client timeout. 60 render frames is 0.42 s at 144 Hz and 0.83 s at
    72 Hz. Change to 2 s of server time and an explicit leave message.
    Check: a far entity silent 1.5 s stays. Planted defect: frames counted.
  - Join reply. A whole snapshot hits the 256 KiB reply cap at 2621 rows.
    Change to the budget's stream from an empty baseline. Check: 5000
    entities in view join without the cap. Planted defect: the snapshot.

  :: details Kept
  The 60 Hz simulation: the logbook's runs at 60 and 120 Hz part at tick 0,
  so a change is a new simulation. The 100-byte row, as the spec emits it.
  The 50 migrations a tick: a running crowd crossing a 100-metre seam is about
  20 a tick at 60 Hz. zstd level 3, with no dictionary until recorded traffic
  shows one helps.
  """
end
