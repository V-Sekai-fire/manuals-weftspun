# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2271. `mix rfd.render` renders rfd/2271-headset-eye-tracking-to-social-vr-without-a-bridge/README.md
# and DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2271 do
  use RFD.DSL

  rfd 2271, "headset eye tracking to social VR without a bridge" do
    state :discussion

    feature "the headset's own eye tracking drives a social-VR avatar's eyes
and blinks, from one program on the headset and no desktop bridge"

    scope "frameeyeosc (V-Sekai-fire/frame-eye-osc): a Lean 4 program on the
headset, the eye-tracking service's shared memory and the social-VR client's
OSC ports"

    decision ~S"""
    frameeyeosc is a Lean 4 program that runs on the headset, reads the
    eye-tracking service's shared memory and sends OSC straight to the
    social-VR client: the client's native eye and blink addresses, plus the
    unified-expression v2 floats. It learns the avatar's own parameters from
    the client's OSC output on UDP 9001 and merges them with a fallback set.
    A held closure is read from the service's extra estimates, not from
    openness. A watchdog re-opens the 9001 listener when it goes deaf.
    """

    problem ~S"""
    The headset tracks eyes, but nothing carried that to an avatar without a
    desktop bridge in between, and the service's shared memory has no
    published layout. Raw openness does not drop while an eye is held shut,
    so a blink that lasts reads as open.
    """

    related ~S"""
    - RFD 2262 (make it with the pen), where faces belong to the Car. This
      is standalone enabling work, not a vehicle.
    """

    drafted_by :ai

    details_title "headset eye tracking to social VR without a bridge"

    details "The shared-memory layout, checked", ~S"""
    The layout was reverse-engineered and is kept twice: as signatures in
    `.sigs`, and as a Lean table of offsets the reader is built against.
    Proofs cover the table; `plausible` and a witness-DAG falsifier run
    against deliberately broken controls, so a check that passes on a
    broken layout fails the build.
    """

    details "A held closure", ~S"""
    Openness stays high while an eye is held shut, so it cannot mark the
    closure. The sum of `estimate_extra[4..7]` does: about 0.002 open and
    0.014 shut, AUC about 0.98, held-out accuracy 0.874 and recall 0.936.

    A cue-aligned face sheet on 2026-09-27 matched 8 of 9 closed tiles and
    9 of 9 open ones.
    """

    details "The deaf listener", ~S"""
    After headset reboots the UDP 9001 listener stopped receiving while the
    service still reported active, so the avatar's parameters stopped being
    learned without any error. Commit `1833fca` re-opens the listener on a
    watchdog, backing off from 15 s to 120 s, and logs a heartbeat every
    5 minutes. The parked items are listed in the repository README
    (`266ca7d`).
    """
  end
end
