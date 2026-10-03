# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1007, "Motion validation (Kimodo)", :discussion do
  feature "motion validation"
  attest_in :none

  prose ~S"""
  :: decision
  Replace the publish validation with a Kimodo motion validation
  stage. The stage runs after auto rigging in the Studio pipeline.

  The stage posts a text-to-motion job. The default prompt is a
  gentle idle breathing loop. Playback on the rigged avatar exercises
  the skeleton. A completed job proves the rig works.

  The stage stores the motion URL on the motion_validation node. The
  export node carries the mesh URL and the motion URL. The companion
  runtime consumes the motion for talk to your VRM.
  :: problem
  The old flow ended with a publish step. Publishing validates the
  package, not the avatar rig. The user needs a terminal check that
  the rig works. The motion clip also feeds the companion runtime.
  :: references
  - Executor: `src/library/studioGraphExecutor.js`
  - Motion: `src/library/kimodoMotionLoader.js`
  - Motion: `src/library/playViewportMotion.js`
  :: related
  RFD 1002 places the stage in the pipeline. RFD 1011 records the
  publish flow that this stage replaces.
  """
end
