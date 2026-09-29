# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2283. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2283-play-mode-verification-by-recording/; the Markdown is a build artifact
# (RFD 2232).
defmodule RFD2283 do
  use RFD.DSL

  rfd 2283, "play-mode verification by recording" do
    front_matter ~S"""
    ---
    name: rfd-2283-play-mode-verification-by-recording
    description: >-
      When avatar motion misbehaves in the Editor: record every frame, read it back
      slowly, pose through humanoid muscles, and prove the simulation is live.
    tools: Read, Edit, Bash
    ---
    """

    state :prediscussion

    flight_level :l1

    feature "a motion defect is measured frame by frame from a recording, with
a control that fails when the simulation is not running"

    scope "the engine editor's update loop, HumanPoseHandler, bone physics in play
mode, render-to-texture contact sheets"

    decision ~S"""
    Verification records. An update callback samples transforms every frame
    into a CSV and renders every fifth frame, and the reading is slow:
    sweep, step size and drift per bone. A pose goes through the humanoid
    muscles, since sampling a humanoid clip onto an avatar leaves the arms
    unposed. Every recording carries a control: disturb the root and see the
    chain move, which shows the simulation runs when a later result is still.
    """

    problem ~S"""
    A defect seen live cannot be measured, and a check that reads a still
    chain cannot tell settled from not simulated.
    """

    related "RFD 2281 (face shapes, the render-and-diff method); RFD 2277 (motion
from our own models, not an avatar's bundled clips)."

    drafted_by :ai

    details_title "play-mode verification by recording"

    details "What it caught", ~S"""
    - Hair tips swept about 930° in 0.93 s together, so the root rotated,
      not a chain. Seven bone-physics chains shared that root, and two had one
      effective child. A single-child chain treats its root as a bone, so
      both rotated it. Re-rooting each on its child stopped the sweep.
    - Control: a 30° yaw at frame 10 moved a tip 41 mm, about a golf
      ball, and it settled over 80 frames.
    - A NaN-scale bone from a delete-shape bake left 38 vertices at NaN, and
      an Invalid AABB followed wherever the mesh was baked.
    """

    details "Traps", ~S"""
    - `AnimationMode.SampleAnimationClip` on a humanoid clip leaves renders in
      the bind pose while `BakeMesh` still reads the pose. Set muscles through
      `HumanPoseHandler` and confirm a hand moved before trusting a render.
    - Disabling the Animator to hold a pose removes the per-frame reset, so a
      spin seen then is re-tested with the Animator on before it is blamed on
      the avatar.
    - Scene changes made in play mode are lost; fixes are applied after
      stopping, then verified in a fresh play session.
    """
  end
end
