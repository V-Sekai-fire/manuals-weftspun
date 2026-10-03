# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2286, "A phone body and face bridge to social VR", :prediscussion do
  feature "a phone's camera drives a social-VR avatar's body and face, tracked
by the workspace's own RF-DETR heads and bridged through the headset"
  scope "the one Godot binary on the phone; RF-DETR segmentation and keypoint
heads as godot-sandbox guests on ggml-rd; frameeyeosc on a standalone headset
or a PC VR host, its OSC input and avatar-parameter plan"

  prose ~S"""
  :: decision
  The phone runs the one Godot binary and tracks the whole body,
  occluded or not: RF-DETR's segmentation head masks the person, face,
  eyes and mouth, and a whole-body keypoint head places the 133 COCO
  whole-body points with a confidence each, both as godot-sandbox
  guests on ggml-rd (RFD 2272). The body solves to a SOMA-X pose (RFD
  1171) and the face to ANNY's 52 facial-action weights (RFD 2253).
  Both go over OSC, each joint with its confidence, to the headset
  bridge, frameeyeosc (RFD 2271), on a standalone headset or a PC VR
  host. It keeps its own tracking for any joint that arrived occluded,
  maps the rest into the avatar's parameters, and sends one stream.
  `DETAILS.md` gives the stretch goals: multiview and egocentric.
  :: problem
  A phone's camera sees the face and often the body; a headset sees only
  the eyes. A vendor's face-tracking framework ties the bridge to one
  platform, while RF-DETR on ggml-rd runs on any GPU the RenderingDevice
  drives. The keypoint head in use detects 17 body keypoints; the bridge
  needs the 133-point whole-body head, which RFD 2203's corpus labels.
  :: related
  - RFD 2271 (headset eye tracking to social VR), the headset bridge.
  - RFD 2272 (RF-DETR segmentation on ggml-rd), the heads' runtime.
  - RFD 2253 (a character creator on ANNY), the 52 facial actions.
  - RFD 1171 (the presence loop), keypoints to SOMA-X to ANNY.
  """

  details_title "A phone body and face bridge to social VR"

  prose ~S"""
  :: details Stretch goals
  **Multiview.** Several cameras watch the same body. Each runs the
  whole-body head, the rig is calibrated as RFD 2190 describes, and the
  bridge fuses each joint across views by confidence, so a joint one
  camera loses another still reports.

  Unsynchronised cameras start their frames at different phases and
  drift apart, and a rolling shutter exposes each row of an image at a
  different time. Where every camera accepts a generator lock, one
  shared timing reference starts each frame on all of them at once.
  Most cameras do not, and a phone that lists generator lock documents
  no way to feed it a reference, so the default path needs no shared
  shutter.
  Each device stamps every frame with its sensor's exposure time on a
  clock shared over the local network, and a flash or chirp that every
  camera sees or hears measures the offset left over. Each view's
  joint tracks are interpolated to one common instant before fusing,
  using each image row's own exposure time for the rolling shutter, and
  a short exposure keeps fast motion from blurring.

  **Egocentric.** The headset's own cameras see the wearer's body from
  above. The split follows EgoExoMoCap (MIT): an estimate from the
  egocentric stream finds where the body is in the other views, and
  those views refine it. Its SMPL-H body model carries a
  non-commercial licence and its training data does not come from us,
  so neither is used. The same method is trained on SOMA-X instead,
  from the anny-soma corpus's constructed renders (RFD 2203).
  :: details References
  - RF-DETR (doi 10.48550/arXiv.2511.09554), the
    segmentation and keypoint heads.
  - COCO whole-body keypoints (Jin et al., doi
    10.1007/978-3-030-58545-7_12), the 133-point layout.
  - ANNY (doi 10.48550/arXiv.2511.03589), the body and its 52 facial
    actions.
  - SOMA (doi 10.48550/arXiv.2603.16858), the pose the body solves to.
  - EgoExoMoCap (doi 10.1007/978-3-032-37422-6_6), the egocentric method.
  - SMPL-H (Romero et al., doi 10.1145/3130800.3130883), EgoExoMoCap's
    body model, replaced here by SOMA.
  """
end
