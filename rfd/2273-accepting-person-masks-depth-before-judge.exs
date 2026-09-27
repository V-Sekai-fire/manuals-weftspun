# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2273. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2273-accepting-person-masks-depth-before-judge/; the Markdown is a build
# artifact (RFD 2232).
defmodule RFD2273 do
  use RFD.DSL

  rfd 2273, "accepting person masks: depth before a judge" do
    state :discussion

    flight_level :l1

    feature "a person mask is accepted by agreement with a depth edge, not by
a vision-language judge"

    scope "datasource-anny-render-corpus PR #41: instance, edge and acceptance
for person masks, and the CC0 VRM pilot that calibrates them"

    decision ~S"""
    Three models, one job each. RF-DETR picks the instance, BiRefNet_HR
    matting (MIT) draws the edge, and agreement with a MoGe-3 (MIT) depth
    edge accepts the mask. Stock EditScore is not the judge: it agreed with
    the depth check on 6 of 23 frames. A grader that judges masks is the
    compact retrain RFD 2262's grade that teaches calls for. A 300-image CC0
    VRM pilot with exact masks and metric depth is the calibration
    reference; scaling that corpus is parked.
    """

    problem ~S"""
    Person masks on social-VR frames have no ground truth, so something has
    to decide which masks to keep. The obvious judge, the grader the loop
    already has, turned out not to judge masks at all.
    """

    related ~S"""
    - RFD 2262 (make it with the pen), whose grade that teaches is the retrain.
    - RFD 1147 (what EditScore costs and returns), the stock grader.
    - RFD 2193 (EditScore reproducibility bar) and RFD 2268 (the recommender).
    - RFD 1173 (multimodal pipeline), MaskScore. RFD 2272, the segmenter.
    """

    drafted_by :ai

    details_title "accepting person masks: depth before a judge"

    details "The edge", ~S"""
    On 23 social-VR frames, BiRefNet_HR matting over the RF-DETR instance
    moved edge agreement at the cell from 0.66 to 0.81, and the median
    distance from mask boundary to depth edge from 10.3 px to 4.9 px.
    """

    details "The acceptance", ~S"""
    Depth-edge agreement ranked the best mask above damaged copies of it on
    23 of 23 frames, so it separates a good edge from a broken one.
    """

    details "Why not the stock judge", ~S"""
    Stock EditScore (Qwen3-VL-8B with its LoRA) agreed with the depth check
    on 6 of 23 frames. A decision-model readout, the logits at the score
    slot with no reasoning generated and the frame prefix shared, is about
    12x faster than generating reasoning but ranks only 0.42 to 0.52
    (Spearman) against it. Neither form is a mask judge; the retrain belongs
    to RFD 2262.
    """

    details "The calibration reference", ~S"""
    300 CC0 VRM avatars rendered in Mitsuba 3, with exact masks and metric
    depth by construction. It is constructed synthetic data, and the
    reference the thresholds above are read against. Scaling it is parked
    until a vehicle needs more.
    """
  end
end
