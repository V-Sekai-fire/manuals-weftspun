# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2344, "dev.3, the proof of dev.2", :committed do
  feature "every dev.2 claim, run under the private working agreements, with its control
seen to fail"
  scope "the pen and the tray at the pins of RFD66606-2343; no new feature"

  prose ~S"""
  :: decision
  dev.3 proves what RFD66606-2343 lists and adds nothing. Each dev.2 gate runs on
  the pinned double editor with a real renderer, on OXRSys and flat, and each of
  its controls is seen to fail as planted. A claim with no passing run is a
  counted gap, not a feature.
  :: problem
  The pen's gates were written on the FOSS side, several run headless, and none
  has run under the private pins. Until they do, dev.2 is a list, not a result.
  :: related
  - RFD66606-2342, dev.1; RFD66606-2343, dev.2; RFD66606-2341, dev.next.
  - The private brief, the private blocklist and the private pitfalls list.
  """

  details_title "dev.3, the proof of dev.2"

  prose ~S"""
  :: details How every run is made
  The pinned double editor from our Godot double build, never headless: a
  small windowed `--resolution` where a gate's own usage line says
  `--headless`. XR runs use OXRSys as the runtime and `xr_pilot_mcp` to see and
  drive. Each command, its pins and its output go verbatim into
  `logbook/logbook-dev3.md`.
  :: details Gates and controls
  1. `gate_xr_scripted.gd`, XR and flat: 6 strokes, 2 cycles, 2 openings, one
     shell. Controls: `--control=drop_seam` FAILs at MESH; `--expect=xr` with
     the runtime hidden FAILs as flat.
  2. `gate_replay.gd`, through OXRSys and from `tools/strokes/skirt.usda`, and the
     CASSIE dress layer. Control: `--control=drop_seam` FAILs at MESH.
  3. `gate_statue.gd`: the skirt lands in the statue's body frame and shows on
     it. Controls: `on_monument` and `canvas_frame` each FAIL.
  4. `gate_world_grab.gd`: carry 0.30 m within 5 mm, scale 2x within 2 %, one
     grip holds within 1 mm. Control: `cold_debounce` FAILs on the first grab.
  5. `gate_locomotion.gd`: walk, stairs, refusals, snap turn, teleport, repeat.
     Controls: `step_high`, `no_resolve`, `solid_land`, `no_floor` and `ulp`
     each FAIL.
  6. The tray: its `tools/gate_dev1.exs`, gates 1 to 7 of RFD66606-2342,
     each with its control.
  7. Reliability, over a 30-minute run of gate 1 in XR: at most 1 frame in
     100,000 over 27.8 ms. Control: a planted 30 ms stall every 10,000 frames
     FAILs by count.
  8. Churn: zero pin moves and zero edits to RFD66606-2343 and this file between
     open and tag. Control: a planted pin bump FAILs by name.

  A gate that passes with its control also passing is decoration and counts as
  a FAIL.
  :: details The playtest
  One person on OXRSys draws with the pen for 15 minutes, three sessions,
  rotating the user, a teammate and one trusted outsider. At minute 15: "What
  were you about to draw next?", "Do you want to keep going?", "Did anything
  look wrong or uncomfortable?" Every answer goes in the logbook verbatim.
  :: details The release
  `v<date>-dev.3` on the pen and the tray, `logbook-dev3.md`, and the counted
  gaps. The gaps and RFD66606-2341's items plan dev.4.
  :: details The pins, the same as RFD66606-2343
  Each pin is the commit or release the dev.2 logbook names.

  - Engine: our Godot build fork's release v20260930-double.1.
  - Our meshing pen and our curvenet interactor.
  - Our XR pilot interactor: OXRSys and xr_pilot_mcp.
  - The tray's dev.1 build.
  """
end
