# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1048, "Model image for voxhammer_image_mesh_editing", :discussion do
  feature "model packaging"
  attest_in :none

  prose ~S"""
  :: decision
  Share the domain with RFD 1047. `voxhammer_mesh_editing` in
  `0047-voxhammer-text-mesh-editing/domain.ex` carries both. The
  `mode` variable picks the branch.

  See `DETAILS.md` for the mode branch, the model's shared-weight cost,
  the `predict()` interface, and why the same preserve-outside guard
  applies here too.
  :: problem
  This is the image variant of RFD 1047. It edits a mesh region from a
  reference image, and not from a sentence.

  The two variants share every stage except the conditioning. Two
  domains would drift, and a drifted guard is a moved vertex.
  :: related
  RFD 1047 holds the shared domain. RFD 1038 holds the weights. RFD
  1053 gives the layer rule.
  """

  details_title "Model image for voxhammer_image_mesh_editing"

  prose ~S"""
  :: details The mode branch
  ```elixir
  mode: %{type: :ref, init: %{conditioning: "image"}}
  ```

  `apply_edit` holds one alternative per conditioning. Each one checks
  `/mode/conditioning`, thus the planner takes exactly one.

  `interactor-voxhammer-image-mesh-editing` holds `problem.ex`, and takes
  the domain from RFD 1047's repo. RFD 1000 keeps one source per design,
  and the domain is that source.
  :: details The model
  | Property   | Value                             |
  | ---------- | --------------------------------- |
  | Parameters | 0. It shares the RFD 1038 weights |
  | bf16       | 8.0 GB, the RFD 1038 cost         |
  | License    | MIT                               |
  :: details The interface
  | Input     | Type | Default |
  | --------- | ---- | ------- |
  | mesh      | Path | none    |
  | reference | Path | none    |
  | region    | Path | none    |
  | seed      | int  | -1      |

  `reference` is an image of what the region should become. It is not a
  texture, and the model does not paste it.
  :: details The same guard applies
  `a_decode` requires `/have/preserved_outside`, exactly as in RFD 1047.
  The conditioning changed, and the loss in the inversion did not.
  """
end
