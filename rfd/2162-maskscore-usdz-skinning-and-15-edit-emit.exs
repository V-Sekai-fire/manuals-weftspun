# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2162, "MaskScore Video-stub USDZ skinning + 15-edit emit", :discussion do
  feature "proper 104-joint skin bindings inside the Video-stub USDZ,\nplus emit coverage of the 5 pose edits added alongside the 10 face\nedits under RFD 1173."
  scope "`6-datasource/anny-render-corpus`"

  prose ~S"""
  :: preamble
  Shelved 2026-09-02: 2162.1 (104-joint ANNY skeleton in USDZ) shipped in
  weftspun/anny-render-corpus#34. 2162.2 (mesh 15-edit expansion) needs
  render capacity currently unbudgeted; resume when local GPU frees.
  :: decision
  Extend `compute_blendshape_targets.py` to also emit the joint bind
  and rest transforms plus vertex-bone weights ANNY exposes at
  `vertex_bone_indices` and `vertex_bone_weights`. `emit_video_usdz.py`
  writes them under the mesh's `SkelBindingAPI` and populates
  `SkelAnimation.jointTransforms` from each candidate's `pose_soma`.

  Also update `maskscore_rung_1_stubs.py` to include the 5 pose edits in
  the 5-stub (mesh/depth/pose/keypoints/multimodal) emit so all 15 edits
  appear in the ETNF parquets.
  :: problem
  The Video-stub USDZ shipped in the Rung 1.5 first pass writes a dummy
  1-joint skeleton. The 10 face edits animate correctly because their
  work happens in `SkelAnimation.blendShapeWeights`. The 5 pose edits
  (head_tilt, head_nod, head_turn, jaw_open_bone, shoulders_up) added
  next need `SkelAnimation.jointTransforms` time samples over the real
  104-joint hierarchy (ANNY total; SOMA canonical pose is 78 pose params at anny call time = 77 Kimodo rotvecs + anny-prepended root, task #76),
  and skin weights per vertex, or the animation plays back as a rest pose.
  :: related
  Spine: urn:oid:1.3.6.1.4.1.66606.1.1.1173 (MaskScore).
  Superseded first-pass USDZ from PR #34.
  """
end
