# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2298. `mix rfd.render` renders
# rfd/2298-the-first-rungs-dev-next/README.md and DETAILS.md from
# this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2298 do
  use RFD.DSL

  rfd 2298, "the first rung's dev.next" do
    state :discussion

    flight_level :l1

    feature "the placeholder for dev work not yet assigned to a numbered rung"

    scope "the pen's work that waits for a dev rung of its own"

    decision ~S"""
    dev.next holds everything not yet assigned to a dev rung, and an item
    leaves it when a numbered rung is planned.
    """

    problem ~S"""
    Work that no rung has claimed needs one place to wait, or it is
    lost between rungs.
    """

    related ~S"""
    - RFD 2293, the workspace, the ladder and dev.1; its release rules hold here.
    - RFD 2296, dev.2; RFD 2297, dev.3; RFD 2298, dev.next.
    """

    drafted_by :ai

    details_title "the first rung's dev.next"

    details "dev.next: a placeholder for everything not yet assigned to a dev rung", ~S"""
    It holds the work that waits for a rung of its own, and an item moves
    out of it into a numbered dev rung when that rung is planned:

    - one player with a body: the walker, rx's player controllers and
      motion.elf merged into one player in rx's `sar_game_framework`
      through a MuJoCo-backed movement component, vendored into the pen;
      motion.elf at double driving Mire, the headset player's avatar,
      seen in a mirror, with a foot-slide gate measuring planted-foot
      drift in millimetres against the source clip's own;
    - the joy forecasts below shown as orbit-view contact sheets, composed
      as RFD 2294's visual comparisons are and rendered by Mitsuba inside
      a godot-sandbox guest ELF on the CPU, with the world grabbed, turned
      like a model and recorded as a video;
    - Maro as the dress-on statue beside the plaza monument, with a pen
      to draw on it;
    - the runs that need the owned GPU: the persona reaching the platform
      and climbing the stairs through oxrsys and PyroWave, each radial beat
      inside the head-camera frame; `gate_xr_scripted --expect=flat`; the
      compute-rd and ggml stage runs; and the GPU Maro fit timed against
      the CPU baseline;
    - the `street` and `railway` modules, then `crossing`, `houses`,
      `vehicles`, `poles`, `props`, `shopsA`, `shopsB`, `trains`,
      `characters` and `petals`;
    - touch-class controller bindings generated from motion-guest's route
      table;
    - the station's crowds (contract-zone-backend#111), capsule shadows
      (#110) and its drawn materials (#72);
    - rx's scripts shipped as `.sgd` (#92) on the merged-compiler addon
      (#87);
    - the PyroWave encoder pipelined to hold 144 Hz;
    - no hand-placed colliders: every collider decomposed from its mesh
      by CoACD running as a godot-sandbox guest ELF over ggml-rd and
      compute-rd, and handed to the MuJoCo guest;
    - the headset path: the release uploaded to the Frame as a
      development title, the Frame streaming from the desktop over
      oxrsys, and the extra companion controllers.
    """

    details "Which features are likely to bring joy", ~S"""
    Each forecast uses RFD 2293's sense-of-wonder rubric and RFD 2295's
    tag form.

    | rung | feature | criteria | joy |
    | --- | --- | --- | --- |
    | dev.next | drawing a garment onto Maro | sense, surprise, motivation | (likely, p=0.80) |
    | dev.next | companion controllers drawing alongside | emergence, sense | (likely, p=0.70) |
    | dev.next | Mire's body, met in the mirror | sense, motivation | (likely, p=0.70) |
    | dev.next | trains, petals and walkers | surprise, motivation | (likely, p=0.65) |
    | dev.next | crowds on the platform | surprise | (even, p=0.55) |
    | dev.next | the station's drawn materials | surprise | (even, p=0.40) |
    | dev.next | PyroWave held at 144 Hz | none | (unlikely, p=0.25) |
    | dev.next | colliders decomposed by CoACD | none | (unlikely, p=0.15) |
    | dev.next | capsule shadows | none | (unlikely, p=0.20) |
    | dev.next | a development title on the Frame | none | (unlikely, p=0.20) |
    | dev.next | the foot-slide gate | none | (remote, p=0.05) |
    | dev.next | `.sgd` scripts, generated bindings | none | (remote, p=0.05) |

    The most joy rests on the drawing, companion and avatar features.
    """

  end
end
