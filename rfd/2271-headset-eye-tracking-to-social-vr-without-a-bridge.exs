# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2271, "headset eye tracking to social VR without a bridge", :discussion do
  feature "the headset's own eye tracking drives a social-VR avatar's eyes
and blinks, from one program on the headset and no desktop bridge"
  scope "frameeyeosc (V-Sekai-fire/frame-eye-osc): a Slang program on the
headset, the eye-tracking service's shared memory and the social-VR client's
OSC ports"

  prose ~S"""
  :: decision
  frameeyeosc is a Slang program that runs on the headset. `slangc -target
  cpp` turns it into C++ that calls libc directly. It reads the
  eye-tracking service's shared memory and sends OSC straight to the
  social-VR client: the unified-expression v2 floats under a configurable
  prefix, and the client's native eye address with `--native`. It ports
  konsti219/frameeyeosc and keeps its per-eye output as the default.
  `--style anime` turns openness into clean close-hold-open blinks per eye,
  and `--learn-port` learns the avatar's own parameters from the client's
  OSC output. Its target is parity with sasaken1102r's fork of the same
  program, rewritten in Slang with Lean tests: no Rust, no new C++, the
  fork read for behaviour and constants only. Eye-camera landmarks come
  from RFD66606-2310 (operator, 2026-10-11).
  :: problem
  The headset tracks eyes, but nothing carried that to an avatar without a
  desktop bridge in between, and the service's shared memory has no
  published layout.
  :: related
  - RFD66606-2262 (make it with the pen), where faces belong to the full product.
    This is standalone enabling work, not a release.
  """

  details_title "headset eye tracking to social VR without a bridge"

  prose ~S"""
  :: details The shared-memory layout
  `src/eye_server.slang` reads versions 4 and 5 of the layout. Version 5
  (SteamOS 0.4.3 and later) inserts the 5-byte Track Dominant Eye Only
  setting at 0x152, which moves the record to 0x157 and the file to 0x4f21f
  bytes. The version is read before the file is mapped, an unknown version
  is never written to, and the next sample is requested in the lock that
  takes the current one: requesting it later halves the rate whenever
  processing outlasts a frame. The daemon retries every second while the
  memory cannot be read. The port matches the reference's lid formula on
  all 7,229 messages of a recorded session.
  :: details Outputs
  `--output vrchat`, `etvr` or `livelink` picks the receiver: the client's
  avatar parameters, VRCFaceTracking's ETVR module (per-eye values,
  relaxed counted as open) or its LiveLink module (Live Link Face packets
  with widening, a steady 50 a second). `--steamlink-params` adds the names
  Steam Link's own OSC uses, and `--eye-tracking-active` sends that flag as
  a bool, a float or not at all. Sends never wait: a datagram the network
  cannot take is dropped and counted.
  :: details The parity ladder
  | Rung | Work |
  |---|---|
  | 1 | the reader: layouts 4 and 5, the request rule, retries |
  | 2 | the outputs above |
  | 7 | the eye cameras: capture helper, ring discovery, landmarks |
  | 8 | a dashboard panel |
  | 3 to 6 | eyelid and gaze rules, a live config and status file, the eye fit, finding the PC |
  Rung 7's capture helper gets CAP_SYS_PTRACE from one step the operator
  runs, and its landmarks come from RFD66606-2310. The order is 1, 2, 7, 8, then
  3 to 6. Installing is a Nushell or Elixir
  installer of ours, not the fork's shell scripts. Runs on the headset are
  allowed while it is in standby, and each wake is reported (operator,
  2026-10-11).
  :: details Tests
  `tests/` is an optional Lean package over `src/core.slang`. Unit checks
  and 7 plausible-witness-dag properties each pair with a control that
  plants the defect they rule out; each rung adds its checks and is shown
  failing on stubs of the old behaviour first. The daemon builds offline
  without it.
  """
end
