# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2282, "pose correctives as bones", :ideation do
  front_matter ~S"""
  ---
  name: rfd-2282-pose-correctives-as-bones
  description: >-
    When a skinned body collapses at a joint: SOMA-X correctives as helper bones and
    constraints, no blend shapes, budgeted against the SDK's Poor rank.
  tools: Read, Edit, Bash
  ---
  """

  flight_level :l1
  feature "a body whose proportions and joint correctives are pure pose:
bone lengths, girth adjusters and constraint-driven helper bones, no blend shapes"
  scope "SOMA-X's corrective MLP as a ggml-rd guest; RFD 2279's
`shapes_to_skin` and `twist_split`; the avatar's bone and constraint budget"

  prose ~S"""
  :: decision
  Ideation. SOMA-X predicts pose-dependent surface correctives for any
  identity model it binds, ANNY included. Sampled at joint poses, its
  deltas decompose into helper bones through `shapes_to_skin`, and the
  roll along a limb into twist bones through `twist_split`. Constraints
  drive the helpers from the parent joints, so the result is pure pose:
  no blend shapes and no runtime drivers, portable as glTF. The MLP runs
  as a ggml-rd guest, since no Python reaches the build.
  :: problem
  Linear blend skinning collapses volume at the shoulder and upper chest,
  and the platform has no pose-space driver for a corrective blend shape.
  """

  related "RFD 2279 (the deform surface: `shapes_to_skin`, `twist_split`,
`pose_corrective`); RFD 2281 (face shapes, the blend-shape counterpart)."
  details_title "pose correctives as bones"

  prose ~S"""
  :: details What SOMA-X supplies
  - A shallow MLP, two hidden layers with ReLU, about 1e8 parameters,
    trained on 80,000 pose and mesh pairs. Apache-2.0.
  - Its correctives apply to identity models that ship none of their
    own. They are body correctives: SOMA-X has no facial model, so the
    eye-closed face correctives stay with RFD 2281's cage path.
  :: details Proportions from ANNY's mesh
  - The reference is ANNY's base mesh, the young adult at age 0.5. Its
    universal average targets are empty on purpose: sex and age live in
    the ethnic targets, so young female is the mean of the three
    `*-female-young` targets, and the default bust is already in it.
  - Compare in 3D, not by outline and not by joints. Segment both meshes
    by the dominant bone of each vertex, map helper bones and both sides,
    and take each segment's principal-axis length and girth over height.
    An outline measures stance, and the rigs place joints differently.
  - Measured on the first avatar: RMS log-ratio 0.213 to young female and
    0.220 to young male. A large head, a short thin torso, thin thighs and
    upper arms.
  - Lengths move a child bone along its parent, so skinning carries every
    garment. Girth is MA Scale Adjuster across the bone. Height is the
    root scale, set last from the measured mesh.
  - A girth change scales the bone-physics colliders on that bone by the same
    factor. Otherwise the chains settle inside the widened layer beneath
    them, which is how a cardigan came to clip the dress in a walk.
  - One pass took the distance from 0.213 to 0.191. Narrowing the head also
    shortened its measured main axis, so the next pass solves the factors
    against the measurement rather than applying them once.
  - Originals are recorded in `Assets/Chibifire/Proportions_original.txt`.
  :: details Garments follow through a cage skin bake
  - A longer torso stretches the body, whose belly blends Spine and Chest,
    and slides a garment weighted to Chest alone: the cardigan rode up by
    the 71 mm the chest moved.
  - Each garment's torso band binds into a tube cage (7 rings of 10 knots
    and two caps) with bhc13. Every knot takes the body's weights at its
    nearest torso vertex, and `cage_bake_skin` carries them through Φ.
    Bone-physics chain weights stay as authored; the humanoid share is replaced.
  - Measured: the dress bound 3,655 vertices and the cardigan 2,525, none
    outside the cage and none with an empty blend.
  - The artist's collider radii scale with the avatar and are otherwise
    kept: fitting them to the skin removed the skirt's volume.
  :: details The budget
  The rank is the worst category and is read from the SDK, never recalled.
  On the first avatar, built through NDMF:

  | category | value | Poor limit |
  | --- | --- | --- |
  | bones | 352 | 400 |
  | constraints | 14 | within Poor |
  | polygons | 78,216 | 70,000 |
  | skinned meshes | 17 | 16 |

  Helper bones spend the 48 bones left under the limit. Polygons, skinned
  meshes and three bone-physics categories block Poor first.
  """
end
