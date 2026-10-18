# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2322, "a Mac dashboard with a launcher and theatre mode", :discussion do
  flight_level :l1
  feature "one OpenXR app on the Mac that shows a launcher of the apps OXRSys Home lists and a
theatre mode that puts a website on a large screen in the headset, recorded from the stream"
  scope "XR Pilot's Apple clients (`oxrsys/clients/Apple/`), its macOS app disk image, and the
recording path of RFD 2307"

  prose ~S"""
  :: decision
  The Mac gets a dashboard: one OpenXR app that runs on OXRSys with Metal. It
  opens on a launcher of the apps OXRSys Home already lists, and its theatre
  mode shows one website on a large flat screen in front of the wearer
  (operator, 2026-10-17). The app draws the screen into its own projection
  layer, so the runtime does not change. A theatre session is recorded from
  the runtime's stream as RFD 2307 states, not by a screen capture.

  It is built smallest first: theatre mode with a fixed address and a
  recording, then pointer input, then the launcher.
  :: problem
  The operator wants to record a website shown in theatre mode on the Mac.
  On the Windows desk, the VR platform's dashboard has a theatre screen. The Mac has a
  desktop launcher and a simulator window, and nothing shows a page in the
  headset.
  :: related
  - RFD 2307, recording the XR Pilot stream: how the session is recorded.
  - RFD 2320, an agent drives the OXRSys simulator: how a gate runs it.
  - RFD 2306, the shared Windows VR desk, where the existing theatre is.
  """

  details_title "how the dashboard is built, and what is not known"

  prose ~S"""
  :: details Sources
  Drafted on 2026-10-17 from XR Pilot's main branch as read that day and the
  operator's choice of a launcher and theatre mode over the Windows desk and
  over a desktop recording.

  :: details What XR Pilot holds today
  - OXRSys Home, a desktop app. It lists app bundles the user adds, starts
    each one with the runtime's manifest in `XR_RUNTIME_JSON`, registers the
    runtime and sets streaming. It has no view in the headset.
  - The OXRSys Simulator, a desktop window that stands in for a headset.
  - The runtime takes Metal swapchains on the Mac. It checks quad layers but
    streams only the projection layer, so a quad from an app is not seen.
    That is why the dashboard draws its screen into its projection layer.
  - No OpenXR app for the Mac is in the repository. The Linux headset client
    and the Android client are the nearest code.
  - The pilot's `--record-stream` option writes the stream to a `.pwrec` file
    on the main branch. The pilot build installed on the Mac is older and
    does not have it.

  :: details The parts
  - Page to texture: a web view in a window that is not shown, captured as
    surfaces the GPU reads without a copy. The first step measures the
    capture rate of a 1920x1080 page; a web view snapshot is the fallback.
  - Screen: a flat rectangle 3 m wide and 3 m away, at eye height, drawn
    into both eyes with the head pose of the frame.
  - Input, second step: a controller ray hits the screen, and the trigger
    sends a mouse click to the page at that point.
  - Launcher, third step: tiles for the apps in OXRSys Home's saved list. A
    tile starts the app the way OXRSys Home does, and the dashboard ends
    its own session first.
  - The address comes from the command line for the first step.

  :: details What is not known
  - Whether a window that is not shown can be captured at full rate. The
    first step measures it; if it cannot, the window is kept on screen
    behind other windows or the snapshot path is used.
  - The page's frame rate in the headset, and the cost on the GPU that
    also encodes the stream. Measured at the first gate, with no claim
    before it.
  - Whether the runtime's Metal path accepts the swapchain format the app
    asks for. The first run reports the formats the runtime offers.
  - How the launcher hands the headset from one app to the next without the
    client dropping. Settled at the third step.

  :: details Gates and controls
  - Theatre gate: the dashboard shows a test page that draws a counter that
    advances every frame. The pilot records two minutes of the stream. The
    gate decodes frames from the recording, finds the counter in the left
    eye and requires it to advance across the run. Control: the same run
    with a blank page fails.
  - Length gate: the recording's own timestamps cover at least 2 minutes.
    Control: a 30 s recording fails.
  - Input gate, second step: a scripted click on a test page's button
    changes the page, read back from the stream. Control: a click off the
    button changes nothing.
  - Launcher gate, third step: a tile starts a test app, whose frames reach
    the stream. Control: a tile for a missing bundle shows an error and
    starts nothing.
  - Each gate runs through the simulator, driven as RFD 2320 states, so no
    person wears a headset for it.

  :: details Where the code lands
  In XR Pilot's repository, as a new app beside OXRSys Home under the Apple
  clients, shipped in the same macOS disk image. The first step updates the
  Mac's pilot build to one with `--record-stream`.
  """
end
