# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2303, "xr technical requirements checklist", :discussion do
  flight_level :l1
  feature "the workspace's own technical requirements checklist for the XR apps it ships,
each item a measurable threshold with the gate that checks it or a counted unchecked entry"
  scope "meshing-pen's XR app, the station, OXRSys and XR Pilot, their releases, and every
recording or render made from them"

  prose ~S"""
  :: decision
  Every XR app the workspace ships passes this checklist before a release:
  launch, frame budget, render scale, robustness, comfort, input, packaging,
  recordings and text, each item a threshold that passes or fails. A 50 s hang
  at launch is a FAIL. Launch time is enforced from outside the process, by a
  watchdog that stops the process tree when the load cue misses its cap.
  `DETAILS.md` lists 33 items; 6 have a gate and 27 are unchecked, named and
  counted so that a missing gate does not read as a pass.
  :: problem
  No item said what a shipped XR app must do, so a load that held the view
  frozen for 50 s had no rule to fail. Store and platform checklists exist,
  and a release here goes through none of them, so the workspace states its
  own, with thresholds it measures.
  :: references
  - `meshing-pen`'s `tools/movie.py`, the launch watchdog, and `tools/gate_replay.gd`,
    the frame-time histogram.
  - `contract-orbit-views`' `STANDARD.md` and `check_orbit_views.py`.
  :: related
  - RFD 2302, the 144 Hz frame budget and guest frame slices; RFD 2287, the
    headset rung at 144 Hz.
  - RFD 2294, video, contact sheets and the Desktop folder; RFD 2283,
    verification by recording.
  - RFD 2271, eye tracking sent as OSC by `frame-eye-osc`.
  """

  details_title "xr technical requirements checklist"

  prose ~S"""
  :: details Precedent
  The checklist draws on a standalone headset store's checks and a console VR
  platform's checklist, as precedent only. Every threshold below is ours,
  picked for the workspace's apps and measured on its desks; none restates a
  number from either source.
  :: details How an item is checked
  An item names its gate, a script with a self-test whose negative control
  fails on broken input, or says "unchecked". An unchecked item is a known
  gap. A gate that only prints a number, such as the frame-time histogram, is
  a measurement and not a gate, and its item counts as unchecked.

  A blocking load cannot time itself: a script inside the process runs only
  when the load returns. Launch is timed from outside. `tools/movie.py` starts
  the engine, waits for the `cue: loaded` line, and when it misses the cap
  stops the process tree, asking first and then forcing.
  :: details Launch
  - L1. A head-tracked frame, the scene or a tracked loading view, within 4 s
    of launch. Why: the view is black or frozen until then; 4 s is the figure
    a standalone headset store's checks use. Gate: unchecked; `movie.py` runs
    with XR off.
  - L2. The scene loaded within 4 s of launch, the same figure as L1
    (operator, 2026-10-04). Why: a load past it shows nothing tracked for
    longer than L1 allows. Gate: `tools/movie.py --load=4`.
  - L3. A 50 s hang is a FAIL. Why: the person has taken the headset off by
    then. Gate: `tools/movie.py` stops the run at the 4 s cap, so a 50 s hang
    fails 46 s early.
  - L4. No black or frozen view during a load: every frame in a load is
    submitted with a tracked pose, with no gap over 6.9 ms. Why: RFD 2302's
    main-loop bound holds during loads too. Gate: unchecked;
    `gate_replay.gd` measures gaps and does not fail on them.
  :: details Frame budget
  - F1. Steady at the target refresh the app declares for the device: at
    least 99% of frames in a 60 s replay under one target interval. Why: one
    miss in a hundred is one visible stutter a second at 90 Hz. Gate:
    unchecked; the histogram measures it.
  - F2. No main-thread block longer than one frame at 144 Hz, 6.9 ms (RFD
    2302). Why: the fastest headset rung runs at 144 Hz. Gate: unchecked;
    `gate_replay.gd` prints frames under 7, 7 to 17 and over 17 ms.
  - F3. The frame rate never drops below the target, and a reprojected
    minimum, half the target, is allowed only when the app declares it. Why: a
    reprojected rate that is declared is a choice; one that is not is a drop.
    Gate: unchecked.
  :: details Render scale
  - S1. At least 85% of the runtime's recommended eye-buffer size per axis
    during play. Why: below it, text and lines soften visibly. Gate:
    unchecked; no app reads its eye-buffer size back.
  :: details Robustness
  - B1. No crash, freeze or unresponsive state in a 60 s replay. Why: any one
    of them ends the session. Gate: unchecked.
  - B2. When the runtime's system overlay takes focus, the app pauses or
    yields within 1 s. Why: input belongs to the overlay then. Gate: unchecked.
  - B3. A removed headset, by proximity or session state, pauses the app
    within 1 s. Why: play that continues unseen loses progress. Gate:
    unchecked.
  - B4. A controller disconnect pauses with a prompt to reconnect within 1 s.
    Why: the person cannot act without it. Gate: unchecked.
  - B5. Lost headset or controller tracking moves the view and the player
    origin by 0 mm. Why: a snap on regained tracking is a comfort fault. Gate:
    unchecked.
  - B6. The system button and suspend/resume are honored, and the app resumes
    within 1 s into the state it left. Why: a resume that resets loses work.
    Gate: unchecked.
  - B7. Save data survives a suspend or a power loss mid-write: a write goes
    to a temporary file and is renamed over the old one. Why: a torn save is
    worse than an old one. Gate: unchecked.
  :: details Comfort
  - C1. No menu is locked to the head; every panel is anchored to the world or
    to a hand. Why: a head-locked panel cannot be looked away from. Gate:
    unchecked.
  - C2. Snap turn, smooth turn and a comfort vignette are all offered. Why:
    people differ in what turning they tolerate. Gate: unchecked.
  - C3. The play-area boundary is respected: no required reach lies outside
    it. Seated and standing play both work, or the app declares the one it
    supports. Why: a reach past the boundary meets a wall. Gate: unchecked.
  :: details Input
  - I1. Controllers and hand tracking both drive every action. Why: a person
    may have either in hand. Gate: unchecked; `gate_xr_scripted.gd` drives
    controllers only.
  - I2. Switching between controllers and hands mid-session keeps input
    working, with no restart. Why: people put controllers down. Gate:
    unchecked.
  - I3. System gestures and system buttons go to the runtime, and the app
    binds none of them. Why: they are the person's way out. Gate: unchecked.
  :: details Eye tracking
  - E1. Eye data is used live and is never written to disk or sent off the
    device without the person's consent (RFD 2271). Why: gaze is personal
    data. Gate: unchecked.
  :: details Packaging
  - P1. Every shipped binary is 64-bit. Why: the targets are all 64-bit.
    Gate: unchecked.
  - P2. The desktop installer is a per-user `.msi`. A `.msix` is denied: it
    needs a trusted certificate before a double-click install works. Why: a
    per-user install needs no administrator. Gate: unchecked; OXRSys's release
    workflow still builds the denied package.
  - P3. `.deb` and `.rpm` packages are built by `nfpm`. Why: the packager
    the allowlist names. Gate: unchecked.
  - P4. The installers are attached to every release. Why: a release a
    person cannot install is not a release. Gate: unchecked.
  - P5. The standalone headset package is signed. Why: the device installs
    only signed packages. Gate: unchecked.
  :: details Recordings and renders
  - V1. 4K, 3840x2160, only; 2K is denied (BLOCKLIST.md). Why: the
    operator's rule. Gate: unchecked; `movie.py` does not read the size back.
  - V2. Recorded by the engine's own movie writer through the wavelet codec
    writer RFD 2294 names, never by external screen capture, which does not
    wait for the engine's startup. Why: a frame-locked writer records no
    startup stall. Gate: `tools/movie.py` fails without the writer.
  - V3. Rendering is capped at 60 s after load. Why: a run past it is hung.
    Gate: `tools/movie.py --render=60`.
  - V4. Videos land on the Desktop under the orbit-view standard's name,
    `YYYYMMDD_project_description_NNNN`. Why: one name finds every take.
    Gate: `tools/movie.py` names it, and `check_orbit_views.py` checks it.
  - V5. Orbit-view cameras come from `sphere_hammersley_sequence`. Why: two
    bundles of one subject compare view for view. Gate: `check_orbit_views.py`.
  :: details Text
  - T1. UI text is set in a regular typeface, Inter, and no pixel font is
    used. A capital letter subtends at least 1 degree, about a pencil's width
    (7 mm) at 40 cm. Why: a pixel font aliases in a headset at any size. Gate:
    unchecked.
  :: details Count
  | Area | Items | Gated | Unchecked |
  | --- | --- | --- | --- |
  | Launch | 4 | 2 | 2 |
  | Frame budget, render scale | 4 | 0 | 4 |
  | Robustness | 7 | 0 | 7 |
  | Comfort, input, eye tracking | 7 | 0 | 7 |
  | Packaging | 5 | 0 | 5 |
  | Recordings and renders | 5 | 4 | 1 |
  | Text | 1 | 0 | 1 |
  | Total | 33 | 6 | 27 |
  """
end
