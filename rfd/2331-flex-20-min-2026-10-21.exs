# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2331, "the 20-minute flex bends isolated limbs past 90 degrees", :discussion do
  flight_level :l2

  feature "the F key in the Model Explorer viewer bends one limb at a time, isolated, past 90
degrees"

  scope "the flex key in the Model Explorer viewer and its flex-quit test"

  prose ~S"""
  :: decision
  The flex key bends one limb at a time, isolated. One arm (shoulder and elbow)
  or one leg (hip and knee) swings past 90 degrees about the limb's natural
  flexion axis and ramps back to rest pose. Only the bending limb's joints move;
  the torso and the other limbs hold at rest pose during the bend. The peak
  bend is raised from 60 to 110 degrees. The motion is a smooth deterministic
  cycle, the same seed every time. The flex-quit test checks the peak, the
  isolation, the smoothness, and the return to rest pose. `DETAILS.md` carries
  the rest of this RFD.
  :: problem
  The current flex wobbles. Every non-root joint swings at once, about its own
  random axis, at its own rate and phase, up to 60 degrees. No limb bends into
  a clearly flexed position past 90 degrees, and no limb is isolated. The
  request is to bend one or two limbs at a time, isolated, past 90 degrees.
  :: references
  - RFD 2314, the SkinTokens Space viewer runs as sandbox guests.
  - RFD 2213, VRM 1.0 loading via a sandbox guest.
  :: related
  - The flex-quit test mode in the Model Explorer guest.
  - The 2-minute skin check in the skin-tokens rig guest.
  """

  details_title "the 20-minute flex bends isolated limbs past 90 degrees"

  prose ~S"""
  :: details The current flex
  - F starts the mode, pauses the model's own animations, and F again stops it
    and returns the rest pose.
  - The mode is 20 minutes long. LENGTH is 1200.0.
  - Each joint except the roots, the bones whose parent is the scene root, is
    collected with a random unit axis, a rate from 0.15 to 0.9 Hz, and a random
    phase from a seeded random generator. SEED is 1.
  - Each frame, each joint's pose rotation is its rest rotation times a
    quaternion about its axis by amplitude times sin(TAU * hz * time + phase).
    The amplitude is DEGREES in radians. DEGREES is 60.0.
  - The label shows a clock: Flex MM:SS / MM:00 (F stops).
  - The test mode, --flex-quit, rigs a model, checks that the joints moved
    (more than 1.0 degree and no more than DEGREES plus 0.01), jumps to the
    end, checks the rest pose came back (back less than 0.001 degree), and
    quits.
  :: details The new flex
  - The same F key, clock, 20-minute length, animation pause, and rest-pose
    return.
  - A deterministic sequence of isolated bends cycles through four limbs: left
    arm, right arm, left leg, right leg.
  - A bend is a smooth ramp. Angle 0 at rest pose to a peak of 110 degrees over
    a ramp-in of 3 seconds, held for 9 seconds, ramped back over a ramp-out of
    3 seconds. The bend is a smooth step. The motion is continuous with no
    jerks.
  - Only the bending limb's two joints move. The torso, the head, and the other
    limbs stay at rest pose.
  - The bend axis is the joint's local X axis, the lateral axis. The sign is
    fixed deterministically to move the joint furthest from rest in the bend
    direction.
  - The whole limb moves together. An arm lifts and folds. A leg lifts and
    bends. The hand and the foot stay at rest pose. The tip adds no wobble.
  - Each pose lasts about 15 seconds. A 2-second rest separates the poses. One
    cycle of four poses and rests takes about 68 seconds. The 20 minutes is about
    17.6 cycles. Each limb bends about 17 times.
  :: details Gates and controls
  The flex-quit test is updated:
  - Past-90 control: at the peak, each bend joint's pose rotation differs from
    its rest rotation by at least 90 degrees. With DEGREES at 60, the old
    value, the peak is 60 degrees and the check fails.
  - Isolation control: while a limb is bent at its peak, every joint that is
    not one of the two bend joints is at rest pose within 0.1 degrees. With the
    old random-axis mode this fails.
  - Smoothness control: the bend angle over a pose rises and falls once, with no
    reversals in the ramp-in or the ramp-out. The old random-axis mode reverses
    and fails.
  - Rest-restore control: after the run ends, every joint is at rest pose, back
    less than 0.001 degrees.
  :: details Where it lands
  - The Model Explorer guest's flex source changes. DEGREES goes from 60.0 to
    110.0. The collection builds the pose sequence (limb, bend joints, axes,
    angles) instead of random axes and rates. The apply bends only the current
    pose's limb over a smooth ramp and holds the rest of the skeleton at rest
    pose.
  - The guest is compiled and re-vendored. The compiled guest ships. No .gd
    ships.
  - The flex-quit test mode carries the checks above.
  This RFD was drafted by an AI and read by a human before it shipped.
  """
end
