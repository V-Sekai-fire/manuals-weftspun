# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2268, "The recommender is a decision model", :discussion do
  flight_level :l1
  feature "the multimodal recommender runs inside the loop as a decision
model, a godot-sandbox guest on ggml-rd that shares its vision-language backbone
with the grader, so what to show a person is decided the way their drawing is
scored"
  scope "interactor-unified-modal-embedder and interactor-multimodal-semantic-ids,
framed as decision models rather than a service beside the loop"

  prose ~S"""
  :: decision
  A recommender is a decision model, not a second runtime. EditScore retrained
  as MaskScore is the template: a frozen vision-language backbone plus a
  decision head, quantized and run as a godot-sandbox guest on ggml-rd. The
  embedder fuses each modality to one 768-dimension content vector; a
  ResidualFSQ head turns that vector into the semantic identifiers the
  recommendation reads. One backbone carries both heads, the grader's and the
  recommender's, so the loop runs a single guest rather than a scorer beside a
  recommender. Detail in DETAILS.md.
  :: problem
  The embedder and the semantic-identifier encoders exist but sit on no plan
  and answer to no runtime discipline. A recommender that needs its own
  service is a second runtime the loop was built to avoid, the same reason the
  grader runs as a guest rather than a workstation model. Nothing yet says the
  recommender is a decision model or that it shares the grader's backbone, so
  it reads as orphaned rather than placed.
  :: related
  - RFD 2262 (make it with the pen and wear it together) names the decision
    models the loop relies on.
  - RFD 2188 (ggml on compute-rd) is the runtime a decision-model guest uses.
  - RFD 2265 (curvenet on compute-rd) is the compute-rd work alongside it.
  """

  details_title "The recommender is a decision model"

  prose ~S"""
  :: details One backbone, two heads
  The embedder freezes a Qwen3-VL vision-language tower and Matryoshka-truncates
  its output to 768 dimensions, the single content vector the recommender
  reads. That tower is the same class of model EditScore and MaskScore are
  built on, so the grader and the recommender share one frozen backbone and
  differ only in the head: a grade head returns the critique, an embed head
  returns the 768-vector. Quantized with a quantized forward during training,
  the shared guest answers both in the sandbox.
  :: details The recommendation is a decision
  A ResidualFSQ head turns the 768-vector into semantic identifiers over text,
  image, mesh, audio and body-phenotype, and the recommendation is the
  identifiers it returns. That is a decision the same way a grade is: the guest
  is asked and answers, on ggml-rd, with no service beside the loop. The
  identifier space and the per-item auxiliary describe an item in one space, so
  a recommendation and a grade read the same content the same way.
  """
end
