# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2263, "the first testable release's simulator gate", :discussion do
  flight_level :l1
  feature "The pen draws a scripted outfit through a simulated OpenXR
hand and curvenet closes it, repeatably, on a desk and in CI"
  scope "transport-meshing-pen's tools/gate_replay.gd,
tools/replay_oxrsys.py and CI workflows; the stage guest ELFs it builds"

  prose ~S"""
  :: decision
  OXRSys is the OpenXR runtime, and tools/replay_oxrsys.py is its hand:
  tracking packets at 90 Hz, a calibration hold, then each stroke with
  the trigger held, thumbstick clicks for boundary mode and the menu
  button to finish. tools/gate_replay.gd runs the pen scene, writes the
  replay plan in the runtime's frame, and passes when strokes made
  equal strokes planned, with 2 cycles and 2 openings. On Linux it
  passes under a software rasterizer in a virtual X server.
  :: problem
  The first testable release (RFD 2262) asks whether a drawn outfit comes back as a
  garment that fits. A person in a headset is the real test, but slow
  and unrepeatable; the simulator is the test that runs on every change.
  :: related
  - RFD 2262 (make it with the pen), whose first testable release this gates.
  - RFD 2234 (dress-on pipeline), the stages the strokes run through.
  - RFD 2255 and 2256, the Bao tunnel and the in-guest transport.
  """

  details_title "the first testable release's simulator gate"

  prose ~S"""
  :: details State by platform
  | Platform | State |
  | --- | --- |
  | Linux | passes: strokes 6 of 6, 2 cycles, 2 openings, lavapipe under Xvfb |
  | Windows | parked: needs a D3D12 app binding on OXRSys's Windows backend, for WARP |
  | macOS | parked: the gate writes its plan, then the engine aborts before a stroke is drawn |

  Holds are counted in engine frames (the gate sends its frame number
  over UDP), because a software rasterizer runs the engine at 5 to 7
  frames a second.
  :: details Saved strokes
  A person's strokes save as OpenUSD: one linear `BasisCurves` prim
  per stroke under `/Creation`, Y up, metres, in the Body frame, the
  boundary mark a per-curve primvar authored only where drawn. usd.elf
  reads and writes them in the guest; Gate S round-trips them against
  the host's OpenUSD. CASSIE's `dress.curves` converts once to the
  same layout, from the train split of a group-wise 60/20/20 split
  whose test set is withheld.
  :: details The graph is CASSIE's, ported literally
  The sketch graph and its cycle detection are a literal port of
  CASSIE's C# (`Graph`, `CycleDetection`, `Node`, `Segment`, `Cycle`),
  not a reimplementation. The C++ guest (`interactor-curvenet`,
  `feat/cassie-graph-port`) is checked event for event against a
  literal Python port of the same classes: 425 of 425 events agree.
  :: details Replaying a recorded session
  A recorded CASSIE session replays CASSIE's own recorded intersection
  constraints as the junctions, never a merge distance and never a
  re-detection. A replayed junction is the recorded point within
  0.1 mm, about an eighth of a credit card; the worst measured is
  0.016 mm, about a fiftieth of one.

  A session's expected cycle count is the patches CASSIE still had at
  the end. The export logs every patch created and none of those
  dropped, and a stroke's patches are logged just before its
  `ADD_STROKE`. A logged patch counts unless it was deleted, holds a
  deleted stroke or that stroke's mirror (id + 1), or was split by a
  later stroke's batch.

  | Session | Patches logged | Alive at the end | Port's cycles | Exact |
  | --- | --- | --- | --- | --- |
  | dress | 225 | 104 | 103 | 101 |
  :: details What may still break
  - The runtime's button bits map to OpenXR paths the pen's action
    map may not expect; the symptom is the wrong number of openings.
  - The reference space may be rotated as well as offset; the
    calibration removes only a translation.
  - Headless engine runs have no rendering device; non-VR runs need
    the XR mode off; redirected stdout is buffered, so results go to
    a file; a quit-after flag never fires with XR on, so the gate
    quits on a wall clock.
  """
end
