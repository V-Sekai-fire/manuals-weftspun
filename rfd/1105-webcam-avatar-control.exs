# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1105. `mix rfd.render` renders rfd/1105-webcam-avatar-control/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD1105 do
  use RFD.DSL

  rfd 1105, "Webcam avatar control, off during WebXR" do
    state :abandoned

    scope "`src/library/webcamAvatarDriver.js`, `xrExpressionTrackingDriver.js`"

    attest_in :none

    decision ~S"""
    The webcam driver does not run while WebXR is presenting. Entering
    VR or AR stops it by itself: it frees the camera, ends the detection
    loop, and returns the avatar to neutral, with nothing left to
    conflict with headset tracking or Galaxy XR. A separate driver,
    `xrExpressionTrackingDriver.js`, takes over inside an immersive
    session, reading the draft WebXR `XRFrame.expressions` feature when
    a user agent grants it. Neither driver touches `enableVR()`,
    `enableAR()`, or reference spaces.

    See `DETAILS.md` for the feature list, the Android XR native-bridge
    path, and remote-logging setup for headset debugging.
    """

    problem ~S"""
    A webcam can drive the current VRM's face and head, using Kalidokit
    plus MediaPipe Holistic, the same approach XR Animator and Kalidoface
    use. That driver must never fight a headset's own tracking once a
    WebXR session presents.
    """

    related ~S"""
    **Unresolved duplicate:** weftspun-3d-studio's own
    `thirdparty/m3/docs/WEBCAM_AVATAR_CONTROL.md` covers the same topic,
    with real content differences. Neither version is authoritative;
    that reconciliation is still open. RFD 1096 gives the Android XR
    native face-tracking path this RFD's XR driver falls back to.
    """

    drafted_by :ai
  end
end
