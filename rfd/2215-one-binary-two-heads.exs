# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2215. `mix rfd.render` renders rfd/2215-one-binary-two-heads/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2215 do
  use RFD.DSL

  rfd 2215, "one binary, two heads" do
    state :discussion

    feature "one runtime serves both the marketing video (headless
capture head) and the game (interactive head)"

    scope "native binary entrypoints for both heads, CineForm video\nmuxing for the capture head"

    decision ~S"""
    One source tree, one CI workflow, one native binary per platform
    (macOS / Windows / Linux), two invocation flags:

    - **Head A, game.** Native window; loads Starforged fixture
      (`starforged.sqlite`), calls `taskweft`'s planner (RFD 2205),
      surfaces the decision-point menu via a Godot Control-node VN
      layout, plays reactions on the VRM portrait via
      `Ggml.run_inference()` (RFD 2230) for motion + VRM expressions
      for face.
    - **Head B, marketing video.** Headless render pass of the same
      binary. `godot --headless --write-movie shot<NN>.<container> ...`
      captures the runway scene per shot; video muxed via CineForm per
      RFD 1123 (ffmpeg blocklisted, see memory `ffmpeg-blocklisted`).

    Same `.tscn` / `.tres` assets, same binary, different invocation
    flag. `DETAILS.md` gives the job flow both heads share.
    """

    related ~S"""
    - [RFD 2210](../2210-atelier-godot-web-shipping-surface/), L3
      strategic bet.
    - [RFD 2216](../2216-threejs-blocklist/), same "one runtime, not
      two" argument.
    - RFD 1123 (CineForm in Godot), Head B's encoder.
    """

    drafted_by :ai

    details_title "one binary, two heads"

    details "Jobs", ~S"""
    Both heads run work as jobs. A job is created in the binary, handed
    to a model through `Ggml.run_inference()` (RFD 2230) or to a module
    of the task catalog (RFD 1102), followed until it is done or failed,
    and stored with its result. A batch is a list of jobs read from one
    manifest and run in turn. Head A shows the jobs in a panel; Head B
    runs them without one.
    """
  end
end
