# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2328, "finger skin weights from a fitted ANNY hand", :discussion do
  flight_level :l1
  feature "an auto-rigged avatar's fingers bend round, without creases, in a fist"
  scope "interactor-headfit, contract-anny-kernels, skin-tokens-ggml and entities-model-explorer"

  prose ~S"""
  :: decision
  For each avatar the auto-rig saves, fit ANNY's hand to the avatar's hand
  with the in-guest L-BFGS-B fitter, then copy ANNY's finger skin weights
  onto the avatar's hand vertices, mapped to the avatar's own finger bones.
  The method is the same for every avatar: no per-avatar settings. It is
  kept only if a measured knuckle-crease score falls on every test avatar,
  with the current rig as the control (operator, 2026-10-19).
  :: problem
  The auto-rig's finger weights crease at the knuckles. In a fist the skin
  folds in small sharp creases where the fingers bend, on the CC-BY-4.0 test
  avatar in a social VR client. The finger bones and the humanoid finger
  data are correct: the asset package's Avatar matches the one the editor
  builds for the same skeleton to 6.1e-7 on all 52 bones.
  :: references
  - ANNY (MPFB2 base mesh, rigs and weights), CC0
  - SOMA-2603.16858 (NVIDIA), Apache-2.0
  :: related
  - RFD66606-1046 (the auto-rig): makes the weights this RFD replaces on the hand.
  - RFD66606-2275 (head fit by a parametric head): the fitter and transfer reused here.
  - RFD66606-2277 (headfit, phase A3): the guest this RFD extends.
  """

  details_title "finger skin weights from a fitted ANNY hand"

  prose ~S"""
  :: details Where the request came from
  The operator saw the creases on 2026-10-19 and asked for a generic fix.
  From the choices offered, the operator picked fitting ANNY's hand with
  the L-BFGS fitter and copying its finger weights, and picked a measured
  crease score on several avatars, before and after, as the proof.

  :: details What exists
  - ANNY's data (interactor-anny, `src/anny/data/mpfb2`, CC0): the base
    mesh in decimetres, the `game_engine` rig with 53 bones of which 30
    are fingers, per-bone weights as `[vertex, weight]` lists, and 22 hand
    targets (finger length, diameter and spacing, hand scale).
  - The fitter (interactor-headfit): reverse-communication L-BFGS-B under
    gas, point-to-plane residual with re-found closest points, a landmark
    start by Umeyama, and a transfer that casts each avatar vertex along
    its normal onto the fitted model and keeps the hit triangle and its
    barycentric weights. It fits shape only (similarity, phenotype,
    local dials) and loads no rig or weights.
  - contract-anny-kernels: forward kinematics, skinning and the vertex
    residual, each with its backward pass. No guest uses them yet.
  - skin-tokens-ggml's robust binding: matched weights, outlier rejection
    and inpainting for vertices with no match, then the four largest
    weights kept.

  :: details The method
  1. Region. The avatar's hand is every vertex whose largest weight is on
     the hand or a finger bone. ANNY's hand is the vertices weighted to its
     hand, metacarpal and finger bones.
  2. Start. Umeyama similarity from landmark pairs: the avatar's wrist and
     its 15 finger joints against ANNY's.
  3. Fit. Unknowns are the similarity, the hand targets, and two angles per
     finger joint (curl and spread; the thumb's base gets three). ANNY's
     hand is posed with the kernels' forward kinematics and skinning. The
     residual is the fitter's point-to-plane term plus the landmark term.
     Joint angles are bounded by the humanoid finger limits.
  4. Transfer. Cast each avatar hand vertex onto the posed, fitted ANNY
     hand as the fitter already does. Blend ANNY's weights at the hit with
     its barycentric weights, with no rotation, map ANNY's finger bones to
     the avatar's by role, and renormalise. Vertices with no hit are
     inpainted by the robust binding. A band at the wrist blends the new
     weights into the auto-rig's.
  5. Place. In entities-model-explorer, `VrmExport._build` replaces the
     hand weights after the finger bones are found and before the bones
     are renamed, so the VRM and the asset package both carry them.

  :: details The crease score
  The avatar is posed in a fist by its own skeleton: every finger joint
  bends 70 degrees toward the palm (the thumb 40), with linear blend
  skinning. The palm is the side of the finger plane the thumb sits on.
  Around each knuckle, the faces within half a finger segment of the
  nearest skin are read. The score of a knuckle is the sharpest fold
  across a pair of faces there: the change of their angle from rest to
  fist, divided by the distance between their centres, in degrees per
  millimetre. A crease folds much over a short span; a round bend spreads
  it, and a coarse mesh bent like a fine one scores the same. A hand's
  score is the mean over its 30 knuckles; lower is rounder. A knuckle with
  no faces to read is named, never skipped. How far the skin caves toward
  each joint is reported beside it. The tool is
  `entities-model-explorer/tools/finger_crease.gd`.

  :: details Rung 0: the baseline
  Mean degrees per millimetre over 30 knuckles, the auto-rig's weights
  against the rigid control (each vertex wholly on its largest-weight
  bone), measured 2026-10-19:
  - CC-BY-4.0 test avatar: 7.26 against 42.72.
  - Mire: 7.45 against 28.74.
  - MIT VRM 1.0 sample: 10.59 against 34.93.
  - Marocchino: 28.39 against 66.09.

  Every avatar's rigid control scores worse, so the score sees a crease.
  Two references did not serve as a floor. The SOMA-2603.16858 mesh with ANNY's
  identity, as retargeted in the stage scratch, scores 45.87: its weights
  there are not ANNY's own MPFB weights. The test avatar's artist rig rests
  with its fingers already curled, so a 70 degree fist overbends it into
  the palm. The floor is ANNY's own hand with its MPFB weights, scored when
  rung 1 loads them.

  :: details Rung 1: measured, and it fails
  ANNY's hand was moved, turned and scaled onto the test avatar's hand
  (a similarity fit on 16 joints, worst joint 14.6 mm after it), then
  each finger bone was turned and stretched onto the avatar's joints.
  Each avatar hand vertex took ANNY's weights from the nearest posed ANNY
  skin, scaled by the hand weight it already had. The score rose from
  7.26 to 31.76 degrees per millimetre. Matching skin by where it sits
  along and around a bone, rather than by nearest surface, gave 37.95.

  The floor explains it. ANNY's own body, with its own MPFB weights,
  scores 65.93 (its rigid control 111.11), and 65.93 again counting only
  the back of the hand. By this score ANNY's finger weights crease more
  than the auto-rig's, so copying them cannot lower it. Rung 1 does not
  pass, and rung 2 (shape) cannot fix weights that are sharper at the
  source. Measured 2026-10-20.

  :: details Gates and controls
  - Test avatars: the CC-BY-4.0 test avatar, Mire and Marocchino
    (Apache-2.0), and the MIT VRM 1.0 sample. Each is auto-rigged first, so
    every avatar is scored on the rig this RFD replaces.
  - Pass: the score falls on every test avatar and no knuckle's skin moves
    more than 2 mm (about one penny) closer to its joint than the
    auto-rig's.
  - Control 1: the current auto-rig scores worse than the new weights.
  - Control 2: rigid weights (each vertex wholly on its nearest bone) score
    worse than the auto-rig, so the score sees a crease.
  - Control 3: a fit started from a wrong landmark pairing (index and
    little swapped) fails the landmark residual.

  :: details Rungs
  - Rung 0 (done): the crease score and its controls, and the baseline on
    every test avatar.
  - Rung 1: transfer with ANNY's hand placed by the similarity and the
    joint angles only, no shape targets.
  - Rung 2: the full fit with the hand targets.

  :: details What is not known
  - Whether a stylised hand (three fingers, a mitten, a paw) fits at all.
    Such a hand keeps the auto-rig's weights, and the report names it.
  - Whether the headfit guest should grow a hand region or a new guest
    should share its fitter. Rung 1 settles it by size of change.
  """
end
