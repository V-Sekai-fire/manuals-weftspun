# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2286. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2286-a-phone-face-bridge-to-social-vr/; the Markdown is a build artifact
# (RFD 2232).
defmodule RFD2286 do
  use RFD.DSL

  rfd 2286, "A phone face bridge to social VR" do
    state :prediscussion

    feature "a phone's front camera drives a social-VR avatar's face, tracked by
the workspace's own RF-DETR heads and sent through frameeyeosc"

    scope "the one Godot binary on the phone; RF-DETR segmentation and keypoint
heads as godot-sandbox guests on ggml-rd; frameeyeosc's OSC input and
avatar-parameter plan"

    decision ~S"""
    The phone runs the one Godot binary and tracks the face itself. Each
    front-camera frame goes to RF-DETR's segmentation head, which masks
    the face, eyes and mouth, and its keypoint head, which places face
    landmarks; both run as godot-sandbox guests on ggml-rd (RFD 2272).
    Masks and landmarks become the 52 facial-action weights ANNY carries
    (RFD 2253). The phone sends those weights over OSC on the local
    network to frameeyeosc (RFD 2271), which maps them into the avatar's
    own parameters with the same plan and bit packing it uses for the
    headset's eyes, and merges the two.
    """

    problem ~S"""
    A phone's front camera sees the whole face, and a headset sees only the
    eyes, so a mouth and brows in social VR need a second sensor. The
    phone's own face-tracking framework ties the bridge to one vendor and
    one class of camera. The workspace already runs RF-DETR on ggml-rd,
    which any GPU the RenderingDevice drives can run. The keypoint head in
    use detects 17 body keypoints; the bridge needs a face-keypoint head.
    """

    related ~S"""
    - RFD 2271 (headset eye tracking to social VR), the program that
      receives the weights and owns the avatar-parameter plan.
    - RFD 2272 (RF-DETR segmentation as a sandbox guest on ggml-rd), the
      runtime the heads use.
    - RFD 2253 (a character creator on ANNY), the 52 facial actions.
    - RFD 1102 (the task catalog), the backend's vendor independence.
    """

    drafted_by :ai
  end
end
