# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2300, "sinew-sim rung ladder", :discussion do
  flight_level :l1
  feature "sinew-sim's sim-first full-body recovery, measured rung by rung before real capture"
  scope "the sinew-sim ladder dev.1 through dev.4, and the measured findings it parks in RFDs"

  prose ~S"""
  :: decision
  sinew-sim recovers the full body in simulation first, then on real renders, climbing dev.1
  through dev.4 and parking each measured finding in the RFD it belongs to before any
  real-motion capture is built. `DETAILS.md` carries the four rungs.
  :: problem
  Full-body tracking needs a measured floor for camera coverage, solver residual and motion
  diversity, or a real-capture rig gets built on guesses. The sinew-sim runs supply that floor.
  :: references
  The sinew-sim repository holds the numpy fusion, RF-DETR (a DEtection TRansformer
  keypoint detector) render and mean per-joint position error (MPJPE) runs these rungs
  cite.
  :: related
  - RFD 2203, the ANNY-SOMA corpus; RFD 2190, the rig extrinsics; RFD 2191, the solver residual.
  - RFD 2189, the stick-figure sanity check; RFD 2192, the keypoint-weights licence check.
  - RFD 1143, keypoints to ANNY; RFD 1045, Kimodo text-to-motion.
  """

  details_title "sinew-sim rung ladder"

  prose ~S"""
  :: details dev.1: distinct orbits beat co-located sensors
  Distinct camera orbits beat co-located sensors. One co-located stereo device carries three
  sensors about 7.5 cm apart, about a soda-can width at 66 mm, on a single orbit. Its fused
  error lands near 146 mm, about two soda cans side by side at 66 mm each. The same sensor
  count spread over three orbits lands near 36 mm, a little under a golf ball at 42.7 mm.
  Camera coverage and tracker count set the floor, not markerless keypoint precision. Markers
  add about 1 mm, about a credit card thick at 0.76 mm.
  :: details dev.2: real RF-DETR on renders
  Real RFDETRKeypointPreview runs on 96 ANNY renders, 8 azimuths by 12 rig positions. It
  detects 95 of 96, which is 99 percent. Median reprojection is 3.9 px. The median 3D ray-gap
  lands near 40 mm, about a golf ball at 42.7 mm. This is ground-truth-free self-consistency on
  one identity in one pose.
  :: details dev.3: absolute MPJPE against ANNY ground truth
  Against ANNY ground truth the absolute error is 5.0 mm median, about seven credit cards
  stacked at 0.76 mm each, and 10.2 mm mean, about one AAA battery across at 10.5 mm.
  Procrustes alignment, rigid and similarity, both hold near 10.1 mm, about one AAA battery at
  10.5 mm, with a similarity scale of 1.0003. The ray-gap overstates the error. It measures RMS
  point-to-ray distance, a consistency signal rather than accuracy. The residual concentrates
  in a per-joint definition offset. Hips sit near 33 mm, about three AAA batteries end to end
  at 10.5 mm each, and shoulders near 13 mm, about an AA battery across at 14.5 mm, where
  Common Objects in Context (COCO) marks a body-surface landmark and the ANNY regressor
  marks an internal articulation centre.
  The other 15 joints average about 7.6 mm, about a pencil width at 7 mm. Ground truth is the
  ANNY regressor's own joints, true by construction for this synthetic pose rather than
  external mocap.
  :: details dev.4: pose and occlusion diversity, parked
  Real motion is not fundamentally blocked. The 100STYLE obstacle is a static per-joint
  bind-orientation offset. The source drive is unmounted, so no source reaches the pipeline
  today. The sanctioned motion path runs Kimodo-SOMA to SOMA-X to ANNY through `anny_from_soma`
  with the ANNY identity. The render-variant tension between reproducible central processing
  unit (CPU) and sanctioned graphics processing unit (GPU) is already settled by BLOCKLIST.md:
  Mitsuba `llvm_ad_*` CPU variants are a render target only for measurement or a card-less
  desk, and `cuda_ad_rgb` on the owned card is the render path.
  :: details Ground truth, the basemesh and the units convention
  Ground truth rides the MakeHuman basemesh topology, 19,158 vertices, that `coco.pth` is
  indexed against. That mesh is posable and coco-regressable. The units convention is
  confirmed: metres equal normalised units divided by scale through `render_view.normalise`,
  where a scale of 0.6025 is the reciprocal of a 1.66-metre stature. A regenerated mesh matches
  the rendered sidecar centre and scale to 2e-16.
  """
end
