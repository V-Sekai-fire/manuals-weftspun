# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2297, "the first rung's dev.3", :discussion do
  flight_level :l1
  feature "the dev rung that follows dev.2 on RFD 2293's release ladder"
  scope "the pen's `v<date>-dev.3` release"

  prose ~S"""
  :: decision
  dev.3 ships each platform's game as one executable with its `.pck`
  embedded, exported at double precision.
  :: problem
  dev.1 and dev.2 shipped the double editor, the addon and the guest
  ELFs, so a player needs a pen checkout to open them.
  :: related
  - RFD 2293, the workspace, the ladder and dev.1; its release rules hold here.
  - RFD 2296, dev.2; RFD 2297, dev.3; RFD 2298, dev.next.
  """

  details_title "the first rung's dev.3"

  details "dev.3: one game per platform, with its pack inside", ~S"""
  Operator, 2026-10-03.

  - macOS arm64: `meshing-pen.app`, with its `.pck` and the addon
    framework inside the bundle, shipped as `meshing-pen.dmg` through
    Godot's standard macOS export. The template `.zip` that export needs
    is an exception the operator granted.
  - Windows x86_64: `meshing-pen-windows.exe` with its `.pck` embedded
    and the addon `.dll` beside it, shipped as `meshing-pen-windows.zip`,
    also by the operator's exception. Linux players run it through
    Proton, so there is no Linux export.
  - Both are exported at double precision from `ENGINE_TAG`'s templates,
    unsigned, by `tools/export_dev3.exs` in CI on a macOS runner.
  - Gate: `tools/smoke_export.exs` launches the exported app until it
    quits and finds `dress_on`, `curvenet`, `usd` and `mujoco` loaded
    from the pack. Its control, the same app with the pack removed, must
    fail. No run forces headless.
  - Orbit views (also called contact sheets, turnaround sheets or
    turntable renders) of the joy features, rendered from the exported
    game on macOS and on the Steam Frame, each with its `.cff` and `.tsv`
    under the contract-orbit-views standard.
  - Playtest: the persona through oxrsys against the exported app.

  dev.2 shipped the double editor, the addon and the guest ELFs for a
  checkout to open instead.
  """
end
