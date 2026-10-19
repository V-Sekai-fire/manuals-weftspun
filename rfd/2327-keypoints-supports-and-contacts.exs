# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2327, "Keypoints, supports and contacts", :discussion do
  flight_level :l1

  feature "one generic keypoint record for detection, motion matching, clip joins and the
avatar, plus what each surface supports and which keypoint rests on which surface"

  scope "the keypoint heads of our RF-DETR port, the motion matching guest, the motion clip cut
of skin-tokens-ggml, the model explorer's motion and walk modes, and the auto-rig's face"

  prose ~S"""
  :: decision
  A keypoint is a named point on a body or on a thing a body touches. Code reads the set as
  data and never writes a name into itself (operator, 2026-10-19). Every record is ETNF:
  - COCO-WholeBody's 133, face included, is the first set because it is the most standard;
    other sets, such as RFD 2310's eye landmarks, are row sets too (operator, 2026-10-19).
  - Its 68 face points map to Unified Expressions (RFD 2275), then the 52 facial actions,
    then SOMA-X's FACS units and extra shapes such as cheek puffs (operator, 2026-10-19).
  - Interaction keypoints are where a body meets something: a seat, a sole on the ground, a
    hand on a grip, a hand on another character (operator, 2026-10-19).
  - A support is a surface with a frame and what it allows (walk, sit, ride, hold): ground,
    chairs, bikes, mopeds, cars and trains (operator, 2026-10-19).
  - A contact puts one keypoint on one support for a span of frames; getting on or off is
    a change of support. The keypoint supports model (RFD 2309's search) sets each
    keypoint's weight and predicts contacts; until then every weight is 1.
  :: problem
  Each system has private keypoints: motion matching measures two feet and the hips on one
  flat ground, the clip cut keeps a one-shot on the spot, the detector emits 17 COCO points.
  None can say a body is seated, which surface carries a foot, or that a rider moves with a
  moped. The first user is a sit-and-stand clip, which Kimodo will not make from one prompt.
  :: related
  - RFD 1143 (keypoints to ANNY) records the joint-count gap between keypoint sets.
  - RFD 2275 is the face, RFD 2310 another set, RFD 2309 the search behind the supports model.
  """

  details_title "Keypoints, supports and contacts"

  prose ~S"""
  :: details Sources
  Drafted on 2026-10-19 from the motion matching guest's core header and README, the
  model explorer's motion and walk-mode scripts, the motion clip cut and its tests, the
  RF-DETR keypoint head, and clip runs of Kimodo at seed 1171 on the desk card.

  :: details What the systems hold today
  - Motion matching takes a list of feature joints by name, today the left foot, the right
    foot and the hips. It scales each feature to unit spread and weights it. It calls a pose
    airborne when both feet are 8 cm above the clip's lowest foot, so the ground is one
    plane per clip. The viewer crossfades for 0.2 s when the matched clip changes.
  - The motion clip cut ends a one-shot on the frame closest to its start pose, fades the
    last frames into it and walks the root back. It reports how far the end pose was from
    the start, so a clip that ends seated is reported, not hidden.
  - The RF-DETR keypoint head is COCO-17. RFD 2310 adds 34 points per eye.
  - The auto-rig's face writes Unified Expressions names from a one-line-per-name catalog.
  - The keypoint anchors place all 133 COCO-WholeBody points on ANNY's 19,158-vertex base
    mesh as vertex blends. The worst face point is capped at 13 mm, about one AAA battery's
    width. A SOMA skeleton such as Kimodo's reaches all 133 through SOMA-X on ANNY.
  - Without the mesh, Kimodo's 30 joints sit on 22 of the 133 points: 14 body, the 2 big
    toes, and each wrist, thumb tip and middle fingertip. Kimodo makes no face motion.

  :: details The records
  Each relation is a table with no nulls and no derived columns. Bulk data is ZStandard
  Parquet; a set edited by hand is `.usda`.
  - keypoint: an interned name.
  - keypoint set: a named set, and which keypoints belong to it.
  - family: body, face, interaction.
  - mesh anchor: a keypoint, a mesh topology and its vertex blend weights, as the keypoint
    anchors hold them.
  - joint anchor: a keypoint, a skeleton joint by name and an offset in that joint's frame,
    for a skeleton without a mesh. A skeleton without that joint has no row, and the
    report names the keypoint as absent.
  - expression map, one table per step so any step can be replaced:
    - the ANNY and SOMA-X fitter solves the 68 face keypoints for the 52 facial action
      weights, the face pose of Table E.13 in our appendix-E dataset;
    - each Unified Expressions name maps to the 52 facial actions, through the headfit's
      catalog (RFD 2275);
    - each facial action maps to SOMA-X's FACS action units;
    - shapes the 52 facial actions lack, such as cheek puffs and the tongue, map from
      Unified Expressions to SOMA-X's extra shapes.
  - support: an interned name and a frame. A support that moves (a bike, a moped, a car, a
    train) carries its frame per frame.
  - support allows: a support and one of walk, sit, ride, hold.
  - surface anchor: an interaction keypoint, a support and a point in the support's frame:
    a seat point, the handlebar grips, a footpeg, a train's floor.
  - contact: a body keypoint, a support and a span of frames. A rider's keypoints are
    stored in the vehicle's frame for the span, which is also what the network wants: riders
    are sent relative to the vehicle they share.
  - weight: a keypoint and a number. Every weight is 1 until the supports model sets it.

  :: details What makes a surface walkable
  The first rule is measured geometry, so a test can check it. Its limits come from the
  body tables of our appendix-E dataset, not from an engine's defaults (operator,
  2026-10-19):
  - the surface faces up within 20 degrees, the normal ankle dorsiflexion of Table E.3-3;
  - a step to it rises or drops no more than a step limit;
  - there is 196 cm of clearance above it, the 99th-percentile male stature of Table E.2-1;
  - there is at least a foot's length of flat area.
  Table E.2-1 has no knee height and no foot length, so the step limit and the flat area
  wait for those rows (see What is not known).
  The keypoint supports model then learns walk from where feet land: in Kimodo clips, in
  the motion matching clips, and in the frontier runs of RFD 2309. A learned rule replaces
  a measured one only when it predicts the landed feet better on held-out clips.

  :: details The first user: the sit-and-stand clip
  At seed 1171, eight single-prompt sit-and-stand wordings at 3 s and 6 s, and three more in
  the motion matching clips' style at 6 s and 10 s, all failed. Most started already seated;
  the best stood, sat and stood again, but its hips fell to 0.18 m (floor height, against
  0.56 m on a chair) and it ended 64 degrees from its start pose.
  Joining the viewer's own sit-down and stand-up clips works. Measured by joint angle, both
  joins differ by 14 degrees, about two ordinary frame steps, and the hips at the seated
  join differ by 3 cm, about one and a half nickels.
  The join, in the clip cut:
  - picks the join frames by keypoint positions in the hips' frame and their speeds, scaled
    and weighted as motion matching does, over the body set of the records above;
  - keeps the seat contact keypoint on the chair support across the seated join;
  - crossfades for 0.2 s at each join, as the walk mode does.
  Gates: the joined clip stands, sits and stands (hips below 0.65 m in the middle, within
  5 cm of the start at both ends); each join moves no more than one ordinary frame step after
  the fade; the seat contact moves less than 2 cm over the seated join. Control: joining
  the stand-up clip to itself must fail the sit gate.

  :: details What is not known
  - The step limit and the flat area. Table E.2-1 has no knee height or foot length. The
    first step adds both rows to the appendix-E dataset from the national surveys it
    already cites, with their percentile columns.
  - Whether a 20 degree slope is the right reading of ankle dorsiflexion. The first check
    compares it with the steepest ground under landed feet in the motion matching clips.
  - How the keypoint supports model reads its training rows. RFD 2309's rows are
    EditScore-shaped; the first step writes one contact row in that shape and checks it
    round-trips.
  - Whether the face weights and the body keypoints share one frame clock. Kimodo makes no
    face motion, so the first user does not test it.
  """
end
