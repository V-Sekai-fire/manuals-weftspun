# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2189, "Stick-figure sanity check for the pose corpus", :discussion do
  feature "cheap visual audit of corpus poses against illustration needs"
  scope "810-clip mocap corpus feeding the atelier-workshop pipeline"

  prose ~S"""
  :: decision
  Draw twenty stick figures by projecting the 104-joint corpus
  through the existing camera arithmetic, ask a character artist to
  review the sheet, and decide whether the corpus fits the
  atelier-workshop (the pipeline) before further capture spend.
  `extract_poses.py` already yields world-space joints; RFD 2190
  (rig extrinsics calibration) will pin the `view` matrices. One
  contact sheet, twenty SVGs. No renderer, no GPU install.
  :: problem
  The 810 clips are locomotion: walking, running, turning,
  standing. Character illustrations are rarely mid-stride. RFD 1122
  (unrolled Kusudama solver) called this the cheapest thing that
  could change the plan and it was never run. RFD 2168 (wholebody
  detector retract) closed without running the check; issue 27
  closed stale. If the artist confirms the mismatch, the pipeline
  takes a different corpus. If the artist accepts it, later work
  has a written verdict.
  :: references
  Original issue: `weftspun/request-for-discussion` issue 27.
  `pose-consensus/python/extract_poses.py`.
  :: related
  RFD 1122 (unrolled Kusudama solver), RFD 2168 (wholebody detector
  retract), RFD 2171 (atelier-workshop vocabulary), RFD 2136 (gacha
  ladder; corpus feeds its rungs).
  """
end
