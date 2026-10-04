# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2301, "sinew-sim dev.4 kimodo-soma motion pipeline", :discussion do
  flight_level :l1
  feature "sinew-sim dev.4 drives varied pose and self-occlusion from Kimodo-SOMA motion"
  scope "the sinew-sim dev.4 pipeline, run once the Kimodo source is reachable"

  prose ~S"""
  :: decision
  dev.4 adds pose and occlusion diversity to sinew-sim. It generates real motion with
  Kimodo-SOMA, drives the ANNY body through `anny_from_soma`, renders on the GPU, and
  measures joint error for each pose. It runs once the Kimodo source is reachable.
  `DETAILS.md` carries the pipeline.
  :: problem
  dev.3 proved accuracy for one body in one rest pose. Whether that accuracy holds
  across varied poses and under self-occlusion stays untested. The obvious motion
  sources are out of reach today: the 100STYLE retarget is unfinished, and the SMPL
  family is blocked.
  :: references
  The sinew-sim repository holds the Kimodo-SOMA inference, the `anny_from_soma`
  bridge, the GPU render and the MPJPE runs this note cites.
  :: related
  - RFD 2300, the sinew-sim ladder; RFD 2203, the ANNY-SOMA corpus and basemesh.
  - RFD 2190, camera coverage; RFD 2191, the solver residual.
  - RFD 1045, Kimodo text-to-motion; RFD 1143, keypoints to ANNY.
  """

  details_title "sinew-sim dev.4 kimodo-soma motion pipeline"

  prose ~S"""
  :: details Motion source
  Kimodo-SOMA is a text-to-motion model that generates novel motion rather than
  replaying a fixed clip library. The `Kimodo-SOMA-*` checkpoints carry the NVIDIA Open
  Model Licence and permit commercial use. `Kimodo-SMPLX-RP-v1` stays out as a SMPL-X
  checkpoint, since the SMPL family is blocked. Kimodo-SOMA emits a SOMA pose.
  :: details Body
  The SOMA pose drives the ANNY body through `anny_from_soma`, with the ANNY identity
  rather than MHR. The pose applies to the MakeHuman basemesh topology, 19,158 vertices,
  so the `coco.pth` regressor gives valid ground-truth COCO joints, the topology dev.3
  measured against.
  :: details Render
  Frames render on the GPU with `cuda_ad_rgb`. The Mitsuba CPU variants are not a render
  target here. BLOCKLIST.md allows them only for measurement or a card-less desk.
  :: details Measure
  Each pose is its own small camera rig, with the cameras orbiting one fixed pose, so the
  dev.3 absolute-MPJPE method applies per pose and the results aggregate across poses. A
  self-occlusion count, the joints seen by fewer than two cameras, reports how a pose
  hides joints. A first pass runs about four poses with twelve cameras each. The bar is
  whether accuracy holds near dev.3's 5 mm median, about seven credit cards stacked at
  0.76 mm each.
  :: details What runs today and what gates execution
  The 100STYLE retarget stays unfinished, a static per-joint bind-orientation offset, and
  its source drive is offline, so no motion reaches the pipeline yet. Two gates stand
  before execution: whether Kimodo-SOMA runs offline here, and whether the bridge from a
  SOMA pose through ANNY to the basemesh topology runs today. A hand-perturbed-pose
  scaffold already sits in sinew-sim as a stopgap while real motion is unavailable.
  """
end
