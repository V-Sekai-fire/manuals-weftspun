# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2191, "Unrolled solver residual measurement", :discussion do
  feature "measure fixed-step Kusudama solver residual vs baselines"
  scope "the unrolled fit RFD 1122 decided on"

  prose ~S"""
  :: decision
  Measure the residual an unrolled fit reaches after K steps, as a
  percentage of stature per `soma_referee.py` convention (a
  millimetre is negligible on an adult and disqualifying on a
  child), against two baselines: `lbfgs_polish.py` run to convergence
  (what the unroll replaces), and K swept from one upward warm-
  started from the previous frame at 120 fps. Compute is trivial:
  one step is 25.6k MAC against 102 GMAC for a four-view backbone,
  0.0006% of the backbone. Waits on RFD 2190 (rig extrinsics
  calibration): a residual against an uncalibrated `view` is in
  unknown units.
  :: problem
  RFD 1122 (unrolled Kusudama solver) decided to unroll the descent
  into a fixed number of steps with a per-step pairwise-Kusudama
  clamp. Whether the residual is good enough was never measured. A
  solver shipped without its residual against a baseline is a number
  without a floor, which PITFALLS rule 4 refuses. Issue 28 on the
  register closed stale.
  :: references
  Original issue: `weftspun/request-for-discussion` issue 28;
  `pose-consensus/python/lbfgs_polish.py` (baseline);
  `pose-consensus/python/soma_referee.py` (reporting convention); `DETAILS.md` carries the floor.
  :: related
  RFD 1122 (unrolled Kusudama solver), RFD 2190 (rig extrinsics
  calibration; blocks this), RFD 2168 (wholebody detector retract).
  """

  details_title "Unrolled solver residual measurement"

  prose ~S"""
  :: details What the residual floor measures against
  The near-40 mm ray-gap, about a golf ball at 42.7 mm, is a pessimistic ground-truth-free
  proxy rather than the residual floor. Measured against ANNY ground truth the floor is 5.0 mm
  median, about seven credit cards stacked at 0.76 mm each, and 10.2 mm mean, about one AAA
  battery across at 10.5 mm. The residual sits in a per-joint definition offset rather than
  triangulation noise: hips near 33 mm, about three AAA batteries end to end at 10.5 mm each,
  and shoulders near 13 mm, about an AA battery across at 14.5 mm. RFD 2300 carries the ladder
  and the per-joint breakdown.
  """
end
