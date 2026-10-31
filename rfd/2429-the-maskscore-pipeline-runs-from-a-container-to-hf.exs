# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2429, "the MaskScore pipeline runs from a container to HF", :discussion do
  flight_level :l2
  scope "the MaskScore corpus pipeline, from input container to the HF dataset."

  prose ~S"""
  :: hook
  The MaskScore corpus is built in one pipeline, from a Docker container per model to HF.
  :: intrigue
  Only 5 of 8 stubs are shipped to chibifire/maskscore-rung-1-bootstrap on HF so far.
  :: exit
  Check a new stub against the diagram: it is a 3-file ZSTD parquet in ETNF with the
  RFD66606-2165.1 schema.
  :: decision
  - The pipeline runs in order: input, render, MaskScore, parquet, HF.
  - Input is a Docker container per model with /health and /predict (RFD66606-1036).
  - The reconstruct model is ggml native per RFD66606-1102.
  :: related
  - RFD66606-1102, where this rule lived before the split.
  - RFD66606-1036, the model container with /health and /predict.
  - RFD66606-2165, the schema of the parquet stubs.
  """

  details_title "the MaskScore pipeline runs from a container to HF"

  prose ~S"""
  :: details Pipeline: MaskScore corpus construction

        input      Docker container per model, /health + /predict (RFD66606-1036)
             |
        render     Mitsuba llvm_ad_rgb or metal_ad_rgb, sphere_hammersley
             |
        MaskScore  mask → reconstruct → score decoded outputs
             |     (reconstruct model = ggml native per this RFD)
        parquet    3-file ZSTD per stub (root + candidates + scores),
                   ETNF (no nulls, interned vocab), RFD66606-2165.1 schema
             |
        HF         chibifire/maskscore-rung-1-bootstrap, 5 of 8 stubs shipped
                   (mesh, depth, pose, keypoints, multimodal, speech)
  """
end
