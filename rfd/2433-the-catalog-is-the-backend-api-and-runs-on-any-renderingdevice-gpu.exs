# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2433, "the catalog is the backend API and runs on any RenderingDevice GPU", :discussion do
  flight_level :l2
  scope "the catalog as the backend API, and its GPU independence."

  prose ~S"""
  :: hook
  The catalog is the backend API, and a module runs on any RenderingDevice GPU.
  :: intrigue
  What if the backend depended on one GPU vendor? A module would then run on that vendor only.
  :: exit
  Call each module's `/health` and `/predict` over plain HTTP, or call
  `Ggml.run_inference()` in process.
  :: decision
  - This catalog is the backend API. The native shell (RFD66606-2215) calls
    each module's `/health` and `/predict` over plain HTTP, or `Ggml.run_inference()` in process
    for an adapter loaded in the binary.
  - The backend does not depend on one GPU vendor. Inference runs on ggml-rd and other kernels on
    compute-rd, both dispatched through Godot's RenderingDevice, so a module runs on any GPU the
    RenderingDevice drives (RFD66606-2272, RFD66606-2265).
  :: related
  - RFD66606-1102, where this rule lived before the split.
  - RFD66606-2215, the native shell.
  - RFD66606-2272, RFD66606-2265, the RenderingDevice dispatch.
  """

  details_title "the catalog is the backend API and runs on any RenderingDevice GPU"

  prose ~S"""
  :: details The endpoint reference
  The per-task table in RFD66606-1102 is the endpoint reference.
  """
end
