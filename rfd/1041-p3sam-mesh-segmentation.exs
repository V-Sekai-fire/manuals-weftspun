# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1041, "Model image for p3sam_mesh_segmentation", :discussion do
  feature "model packaging"
  attest_in :none

  prose ~S"""
  :: decision
  Return the labels as data, and return the split meshes as files. A
  caller that only needs the label array must not pay for a mesh split.

  See `DETAILS.md` for the model's memory and license, the `predict()`
  interface, the output shape, and why the label array leads.
  :: problem
  P3-SAM segments a mesh into parts. It replaces PartField, which
  RFD 1028 removed for a non-commercial weight license.

  The model is small at 0.8 GB in bf16. The packaging risk is not the
  memory. It is the output shape.
  :: related
  RFD 1029 selects P3-SAM and PartSAM. RFD 1028 records why PartField
  went. RFD 1008 records the trait remix that consumes the parts.
  """

  details_title "Model image for p3sam_mesh_segmentation"

  prose ~S"""
  :: details The model
  | Property   | Value            |
  | ---------- | ---------------- |
  | Parameters | 0.4 B, estimated |
  | bf16       | 0.8 GB           |
  | Q4_K_M     | 0.22 GB          |
  | License    | MIT              |
  | Format     | bf16             |
  :: details The interface
  | Input              | Type | Default |
  | ------------------ | ---- | ------- |
  | mesh               | Path | none    |
  | segment_every_part | bool | false   |
  | max_parts          | int  | 32      |
  | seed               | int  | -1      |

  `segment_every_part` is the mode PartSAM and P3-SAM share. It returns
  every part it finds, and it ignores `max_parts`.
  :: details The output
  `predict()` returns a `BaseModel`. It carries `labels`, which is one
  integer per face, and `parts`, which is a list of GLB files.

  A face-length integer array on a 210000 vertex mesh is large. Write it
  as a JSON file, and not as an inline list. RFD 1033 gives the vertex
  cap.
  :: details Why the label array leads
  A part label is stable input for the rig stage and for the remix
  stage. A split mesh is not, because a later decimation renumbers the
  faces. Give the caller the stable thing first.
  """
end
