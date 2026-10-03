# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1038, "Model image for trellis2_image_to_textured_mesh", :discussion do
  feature "model packaging"
  attest_in :none

  prose ~S"""
  :: decision
  Package TRELLIS.2 once, and publish the image as the base for
  RFD 1039, RFD 1047, RFD 1048, and RFD 1049. Those four add a
  `predict.py`, and they add no weights.

  See `DETAILS.md` for the model's memory and license, the `predict()`
  interface, and why both flow stages stay in one container.
  :: problem
  TRELLIS.2 is the default for image to 3D. It is the backbone of four
  other catalog entries. A model image that packages it badly costs five
  models, and not one.
  :: related
  RFD 1036 gives the model image convention. RFD 1053 gives the asset
  format. RFD 1026 gives the memory. RFD 1002 records the pipeline stage
  this model fills.
  """

  details_title "Model image for trellis2_image_to_textured_mesh"

  prose ~S"""
  :: details The model
  | Property   | Value              |
  | ---------- | ------------------ |
  | Parameters | 4.0 B, estimated   |
  | bf16       | 8.0 GB             |
  | Q4_K_M     | 2.20 GB            |
  | License    | MIT                |
  | Format     | bf16, per RFD 1027 |
  :: details The interface
  `predict()` takes the image, the texture resolution, and the face
  budget. It returns the base USD layer, and a GLB beside it. RFD 1053
  gives that rule.

  | Input              | Type | Default |
  | ------------------ | ---- | ------- |
  | image              | Path | none    |
  | texture_resolution | int  | 1024    |
  | decimation_target  | int  | 210000  |
  | seed               | int  | -1      |

  `decimation_target` must not exceed 210000. That is
  `API_MAX_MESH_VERTICES` in src/library/aiModelsCatalog.js, and it
  matches the API upload cap. A larger mesh fails the next stage.
  :: details Two stages, one container
  The sparse structure flow runs first, and the SLat flow runs second.
  Both stay in one model image. They share the DINOv2 image encoder, thus a
  split would load that encoder twice.
  """
end
