# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1045, "Model image for kimodo_text_to_motion", :discussion do
  feature "model packaging"
  attest_in :none

  prose ~S"""
  :: decision
  Return the SOMA result and the VRM result as separate outputs. The
  SOMA output is the model. The VRM output is a retarget, and a caller
  that has its own rig wants the SOMA.

  Do not hide the retarget. A single VRM output makes the model look
  wrong when the retarget is what failed.

  Generated clips also go out as VRMA files in a clip-library repository,
  with a contact sheet of each clip on ANNY (operator, 2026-10-19).

  See `DETAILS.md` for the model's memory, the `predict()` interface,
  and the motion validation gate this model image runs.
  :: problem
  Kimodo turns a sentence into motion. It emits SOMA, and the client
  needs VRM humanoid tracks. The retarget between them is the hard part,
  and it is not the model.

  The model is small at 0.6 GB in bf16. The packaging risk is the
  skeleton contract.
  :: related
  RFD66606-1007 records the motion validation. RFD66606-1005 records the VRM
  pipeline the retarget targets. RFD66606-1026 gives the memory.
  """

  details_title "Model image for kimodo_text_to_motion"

  prose ~S"""
  :: details The model
  | Property   | Value            |
  | ---------- | ---------------- |
  | Parameters | 0.3 B, estimated |
  | bf16       | 0.6 GB           |
  | Q4_K_M     | 0.17 GB          |
  | Format     | bf16             |
  :: details The interface
  | Input            | Type  | Default |
  | ---------------- | ----- | ------- |
  | prompt           | str   | none    |
  | duration_seconds | float | 4.0     |
  | fps              | int   | 30      |
  | target_rig       | Path  | none    |
  | seed             | int   | -1      |

  `target_rig` is optional. Without it the model image returns SOMA
  only, and it runs no retarget.
  :: details The clip library
  The library takes the SOMA result, not a retarget. Each clip poses SOMA-X
  with the ANNY identity, goes through OpenUSD as the intermediate, and is
  written as one VRMA file. The VRMA skeleton holds only humanoid bones at
  the SOMA T-pose. A SOMA joint with no humanoid bone, such as the second
  neck joint or a finger metacarpal, folds into the next humanoid bone, so
  every humanoid bone keeps its world pose.

  The bone map: spine, chest and upper chest come from the three spine
  joints; arm and forearm become upper and lower arm; leg and shin become
  upper and lower leg. Finger joints two to four become proximal,
  intermediate and distal, and the thumb's three joints become metacarpal,
  proximal and distal.

  The contact sheet renders each clip on ANNY at a view from the
  `sphere_hammersley_sequence` camera sequence. A VRMA loader with a
  swapped-clip control checks each file.
  :: details The validation gate
  RFD66606-1007 records the motion validation. A motion that leaves the floor
  or that inverts a knee must fail here, and not in the viewport.

  Run the validation inside this model image, and return its verdict as a
  field. A caller then knows the motion is unusable before it loads it.
  """
end
