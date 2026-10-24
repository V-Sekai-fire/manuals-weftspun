# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2329, "A learned gait phase for motion matching", :discussion do
  flight_level :l1

  feature "a gait phase per frame, learned by a periodic autoencoder from recordings at their own
rate, that the motion matching guest's join rule reads in place of foot strikes"

  scope "the motion matching guest's clip data, phase tools and join rule, and the model
explorer's walk mode"

  prose ~S"""
  :: decision
  The guest joins two cycling poses only when their gait phase matches (RFD66606-2327). A phase
  learned as WalkTheDog does replaces the foot-strike phase once it passes the strike gate;
  until then every clip keeps foot strikes.
  - Every clip stays at the rate it was made at: the open motion-matching recordings at 60
    fps, the Kimodo clips at 30. No frame is resampled or blended (operator, 2026-10-20).
  - The phase model trains on the 60 fps recordings only, on our own card, with the code's
    frame rate setting equal to the data's (operator, 2026-10-20).
  - Training runs with plots off and logs every 50 steps (operator, 2026-10-20).
  - Raw BONES-SEED is not used, as clips or to retrain Kimodo at 60 fps (operator,
    2026-10-20).
  - Runs, checks and contact sheets go to a private dataset of ours, walk-phase-tests.
  :: problem
  Foot strikes give a phase to 78% of frames and miss poses such as the start of a run that
  slows to a walk; at a run the guest returns to that start every 0.7 s unchecked. Four
  learned runs fail the strike gate, worst curves 0.35, 0.21, 0.17 and 0.19 of a cycle
  against 0.06.
  :: related
  - RFD66606-2327, the phase rule for joins and the steady-gait loops; RFD66606-2294, where
    compute runs.
  """

  details_title "A learned gait phase for motion matching"

  prose ~S"""
  :: details Sources
  - Li, Starke, Ye and Sorkine-Hornung, WalkTheDog: Cross-Morphology Motion Alignment via
    Phase Manifolds, SIGGRAPH 2024, doi 10.1145/3641519.3657508. Code MIT; its published
    weights come from other motion sets and are not used.
  - Starke, Zhao, Komura and Zaman, Local Motion Phases for Learning Multi-Contact Character
    Movements, SIGGRAPH 2020: a phase per limb for motion one shared phase does not fit.
  - Kimodo-SOMA-RP's model card: output at 30 fps only, at most 300 frames.

  :: details Clips at their own rate
  The recordings' keys sit 1/60 s apart, so the converter samples them at 60 fps and drops
  each recording's opening rest-pose frame, which snapped into the first pose. Kimodo makes
  30 fps and nothing else; asking it for more frames gives slower motion, not finer frames.
  The guest's core works in seconds so both rates sit in one search:
  - A bone velocity is the central difference over 1/30 s each side, read between frames.
  - The facing averages 0.25 s each side, the edge frames weighted by the part inside.
  Gate: every 60 fps clip against its own every-second frame read as a 30 fps clip, at the
  99th percentile, features within 0.25 of a spread and phase within 0.04 of a cycle. Before
  the change, 0.29 and 0.074; after, 0.024 and 0.031. Control: the twin read at the wrong
  rate fails at 4.0 and 0.43.

  :: details How the phase is trained
  Each frame becomes joint velocities, positions and two rotation columns in the hips' floor
  frame. The run that matches the decision trains on the 21 recordings, 96,417 frames, with a
  2 s window, 8 curves and 50 epochs. Plots off and logs every 50 steps raise the steps per
  second from 19.5 to 29.5 on one card; the training is unchanged. Batches four times larger
  run about 2.7 times faster per epoch but change the training, so they wait for a ruling.

  :: details The strike gate
  A left-foot strike is the frame the foot comes to rest on the clip's floor. On each curve
  with 10 or more strikes, the strikes' circular spread of learned phase stays within 0.06 of
  a cycle. Control: alternate strikes shifted by a quarter cycle must fail.
  - 72 clips at 30 fps with the rate setting left at 60, 32 curves, 10 epochs: worst 0.35.
  - The same with a window twice as long: worst 0.21; 975 of 1,809 strikes on passing curves.
  - The rate setting at 30, 8 curves, 50 epochs: worst 0.17.
  - The 21 recordings at 60 fps, 8 curves, 50 epochs: worst 0.19; 1,169 of 1,866 strikes on
    passing curves; the control fails at 0.25.

  :: details What the failing strikes are
  Contact sheets of the last run show the 12 strikes farthest from each failing curve's phase
  and the 4 nearest. On the turn and pivot curves the far strikes have the feet together and
  a short foot path: a pivot or a shuffle, not a step of a stride. On one curve a free-roaming
  recording's upright steps sit far off while its crouched steps line up. Steady walks, jogs
  and circles sit within 0.02 to 0.04 of a cycle on every curve. A left and right swap is not
  the cause: 15 of 1,872 strikes sit half a cycle off.

  :: details Next steps, ranked
  - The paper's own settings on the 60 fps recordings: a 1 s window and 32 curves.
  - The gate scored on steady strides only, strikes a regular stride apart, with counting the
    pivots again as its control. It changes the gate, so it waits for a ruling.
  - 16 or 32 curves, if crouched and upright walking still share one curve.
  - A phase per foot, as Local Motion Phases does, for turns.

  :: details The Kimodo clips' licence
  Kimodo-SOMA-RP's weights carry its maker's open model licence, version of 2025-10-24. It
  states: "[The licensor] does not claim ownership to any outputs generated using the Models
  or Derivative Models", "An output is not a Derivative Model", and "You are responsible for
  outputs and their subsequent uses."

  :: details What is not known
  - Whether any setting passes the strike gate on turns and pivots, or whether those carry no
    stride phase at all. The ranked steps settle it in order.
  - How many epochs the paper trained; the first ranked step uses the code's default.
  """
end
