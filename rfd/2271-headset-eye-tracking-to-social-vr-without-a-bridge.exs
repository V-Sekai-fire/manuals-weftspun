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
  OSC output.
  :: problem
  The headset tracks eyes, but nothing carried that to an avatar without a
  desktop bridge in between, and the service's shared memory has no
  published layout.
  :: related
  - RFD 2262 (make it with the pen), where faces belong to the full product.
    This is standalone enabling work, not a release.
  """

  details_title "headset eye tracking to social VR without a bridge"

  prose ~S"""
  :: details The shared-memory layout
  `src/eye_server.slang` reads version 4 of the layout, 0x4f21a bytes, and
  refuses any other version or an uninitialized map. The port matches the
  reference's lid formula on all 7,229 messages of a recorded session.
  :: details Tests
  `tests/` is an optional Lean package over `src/core.slang`: 37 unit checks
  and 7 plausible-witness-dag properties, each paired with a control that
  plants the defect it rules out. The daemon builds offline without it.
  """
end
