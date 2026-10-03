# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2266, "The simulator runtime runs on Linux", :discussion do
  flight_level :l1
  feature "the first testable release's simulator gate builds and runs on Linux, on
hardware the operator owns, off the macOS runner"
  scope "the OXRSys runtime build and the transport-meshing-pen replay gate"

  prose ~S"""
  :: decision
  Build the simulator runtime with its Linux preset and run the replay gate on
  Linux. The macOS gate crashed in the macOS Vulkan translation layer on every
  run and never went green; the same session runs to completion on Linux, so
  the crash is that layer, not the pipeline. The runtime prefers a hardware
  HEVC encoder over the software one, which alone costs about a frame at 90Hz.
  A CI runner without a GPU falls back to software, so the Linux gate asserts
  correctness only and performance is measured on the headset (RFD 2265).
  Parked: see DETAILS.md.
  :: problem
  The macOS replay gate has failed on every run since the branch was created,
  a crash in the macOS Vulkan translation layer right after the rig stage, and
  it was never a regression from the saved-stroke work. Separately the runtime
  picked the software HEVC encoder, which spends about 11 milliseconds a frame
  and on its own holds a 90Hz loop below its 11.1 millisecond deadline. The
  gate needs a host the operator owns and a video encoder that leaves the frame
  budget for the loop.
  :: related
  - RFD 2263 (the first testable release's simulator gate) is the gate this runtime serves.
  - RFD 2265 (curvenet on compute-rd) holds the headset performance bed.
  - RFD 2188 (ggml on compute-rd) shares the Vulkan-on-Linux ground.
  """

  details_title "The simulator runtime runs on Linux"

  prose ~S"""
  :: details Build recipe
  The runtime builds with its Linux preset against cmake, ninja, a C++
  compiler, the Vulkan headers, FFmpeg where macOS used its own encoder, and
  the X11, xcb and wayland headers the OpenXR presentation backend needs.
  Configure with the tests, conformance tests and API layers off and the
  toolchain prefix passed explicitly, since the environment manager does not
  export it and the X11 find step fails without it. The runtime links FFmpeg
  on Linux; the encoder chooses a hardware HEVC encoder by name and falls back
  to software when none opens, so a GPU host encodes on the GPU and a
  GPU-less host still runs.
  :: details Parked
  Shelved 2026-09-26. The encoder change is drafted against a scratch clone of
  the runtime and is not yet a pull request on the fork. The Linux CI gate
  that replaces the macOS one is not written; on a GPU-less runner it will use
  a software Vulkan path and a paced replay, asserting the same cycles and
  openings rather than a frame rate. Unpark when the simulator gate moves off
  the macOS runner. The development desktop reaches Vulkan only through a
  Vulkan-over-D3D12 translation layer, which adds about 12 milliseconds a
  frame and so cannot itself measure 90Hz; the headset is the performance bed.
  """
end
