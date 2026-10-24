# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1046, "Model image for skintokens_auto_rig", :discussion do
  feature "model packaging"
  attest_in :none

  prose ~S"""
  :: decision
  Write the rig as a USD layer over the mesh layer. `UsdSkel` holds the
  skeleton, the joint order, and the binding. The mesh layer below stays
  untouched.

  Emit VRM beside it, because the client needs VRM humanoid tracks.

  The rigged GLB is the source file plus the rig: its materials, textures,
  UVs and blend shapes stay, and the rest clip is `RESET` (operator,
  2026-10-18).

  A generated skeleton stops at 256 joints, the count the skin codes cover.
  Twist helpers keep each vertex within four weights and stay on a limb only
  where the measured motion error falls (operator, 2026-10-19).

  See `DETAILS.md` for the model's memory, the `predict()` interface,
  why `UsdSkel` beats a GLB skin, and the joint order trap between VRM
  and USD.
  :: problem
  SkinTokens is the default auto rig. It writes a skeleton and skin
  weights for a mesh that has neither.

  A rig is the clearest case for RFD66606-1053. The rig is an opinion about
  an existing mesh, and a flat file forces the rig stage to rewrite the
  mesh to carry it.
  :: related
  RFD66606-1053 gives the layer rule. RFD66606-1035 records the template rig
  split. RFD66606-1005 records the VRM pipeline.
  """

  details_title "Model image for skintokens_auto_rig"

  prose ~S"""
  :: details The model
  | Property   | Value            |
  | ---------- | ---------------- |
  | Parameters | 0.5 B, estimated |
  | bf16       | 1.0 GB           |
  | Q4_K_M     | 0.28 GB          |
  | Format     | bf16             |
  :: details The interface
  | Input    | Type | Default |
  | -------- | ---- | ------- |
  | mesh     | Path | none    |
  | rig_mode | str  | full    |
  | seed     | int  | -1      |

  `rig_mode` takes `skeleton`, `skin`, or `full`. It does not take
  `template`. SkinTokens rejects template mode, and RFD66606-1035 records
  that UniRig is the only backend for it.
  :: details Why UsdSkel, and not a GLB skin
  A GLB skin binds to one mesh. When the retopology stage later changes
  the mesh, the skin breaks and the rig stage runs again.

  A `UsdSkel` binding sits in its own layer. A new mesh layer below it
  keeps the joint hierarchy, thus only the weights need a rebind.
  :: details The rigged GLB
  The first desktop and web rig wrote a new GLB from the flattened mesh: one
  material, no textures and no UVs. A giraffe with three textured materials
  came back grey, and an alien with five materials came back with one. The
  operator reported it as "the materials are gone" (2026-10-18).

  The rig now copies the source document and adds the joints, one skin and
  the clip. Each placed mesh gets a skinned copy in world space. Normals and
  tangents move by the inverse transpose of the node's transform, a mirrored
  copy flips its winding, and blend-shape deltas move with the mesh. The
  source's own skins and clips are dropped, and bytes nothing references any
  more are removed from the binary chunk.

  The one-frame rest clip is named `RESET`, the name Godot gives the rest
  pose (operator, 2026-10-18). A clip with frames keeps its own name. Motion
  put onto a rigged file is added to that file, first in its clip list, so
  the materials and `RESET` stay.

  Godot reads a scene with one root differently from a scene with several.
  An avatar of 13 skinned meshes and 7 materials opened with no meshes when
  the new joints and meshes were extra scene roots ("Unable to find node"),
  while the glTF validator found no error. Placing them inside the source's
  single root, when that root has no transform, opened it with all 13
  meshes, 52 bones and 16 textured surfaces. Wrapping the whole scene in a
  new parent node did not. A source with several roots, or a moved root,
  still gets the new nodes as scene roots, and no test model of that shape
  has been tried.

  Checks, each with a control:
  - A unit test writes a two-material, textured, mirrored source and reads
    it back. Erasing the materials in the writer fails it.
  - The old writer is the control for the giraffe: one material and no
    texture against three of each from the new one, with the same bone
    deformation.
  - Seven models open in Godot with their materials and `RESET`, and the
    Khronos glTF validator reports zero errors on each. Before the bounds
    fix, it reported missing bounds on 640 blend-shape positions.
  :: details The joint cap
  The skeleton grammar used to drop a beam only after its skeleton ended, so
  a skeleton could grow past the 256 joints the skin codes cover. On one
  humanoid test model, ten sampled beams ran for 41 minutes, reached 371
  joints and failed at the token limit. At 256 joints the grammar now allows
  only the end-of-skeleton token, so such a run fails fast. A unit test
  checks the allowed tokens below and at the cap, and the same test with the
  cap removed fails.

  The command-line rig defaults to the viewer's settings: one beam,
  temperature 0. With those settings the same model came out with 52 joints
  on the CPU and on Metal, and with 206 joints on Vulkan through MoltenVK.
  The Vulkan backend is the open defect, and its cause is not found yet.
  :: details Twist helpers
  The method follows SOMA-X: four helpers on each upper arm, forearm, thigh
  and shin, at 0.05, 1/3, 2/3 and 0.95 of the segment. Each helper takes that
  fraction of the end joint's twist. An upper segment also undoes the rest
  of its start joint's own twist, so the shoulder and the hip do not wring.
  The start joint's weight is split among the helpers by where the vertex
  lies along the segment. The split is one tensor graph on the rig's own
  device.

  A VRM viewer skins with four weights per vertex (operator, 2026-10-19), so
  the step never drops another joint's weight to make room. A vertex with no
  free slot gives its share to the nearer helper only. A unit test puts a full
  four-weight vertex mid-forearm; the earlier keep-the-four-largest rule
  drops three joints there and fails it.

  The score is the worst-frame first-percentile triangle area, posed over
  rest, so 1.0 is no shrink. On one humanoid test model with a dance clip:
  - No helpers: thighs 0.50, shins 0.73, upper arms 0.15, forearms 0.15.
  - Helpers on every limb: thighs 0.43, shins 0.74, upper arms 0.28,
    forearms 0.27.
  - Helpers that follow their start joint without turning score the same as
    no helpers on every limb. That is the control for the measure.
  - Twist directions flipped per limb all scored worse. Flipped arms put the
    forearms at 0.08, so the written direction is the right one.

  The thighs lose for reasons a pure twist test does not see. In the dance,
  thigh motion is mostly swing. Also 206 of the 4,231 thigh vertices carry up
  to 13% hand or arm weight from the generated rig, so the arm helpers pull
  them. A rig-time check that turns each limb by 45 and 90 degrees keeps the
  thigh helpers (0.27 to 0.61), while the dance loses. A limb's helpers are
  therefore judged on a set of generated clips, and they stay only where the
  error over that set falls.
  :: details The joint order trap
  VRM names its humanoid joints. USD does not, and it keeps an ordered
  array. The mapping between them must live in the layer as metadata,
  and not in the exporter.

  An exporter that infers the mapping from joint names fails on any rig
  that names a joint differently.
  """
end
