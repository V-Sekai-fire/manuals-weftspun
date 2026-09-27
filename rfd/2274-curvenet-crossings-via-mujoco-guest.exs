# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2274. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2274-curvenet-crossings-via-mujoco-guest/; the Markdown is a build
# artifact (RFD 2232).
defmodule RFD2274 do
  use RFD.DSL

  rfd 2274, "Curvenet crossings via the MuJoCo guest" do
    state :discussion

    flight_level :l1

    drafted_by :ai

    feature "the curvenet finds stroke crossings through the engine's own
collision, so the crossing test is a proven capsule solver rather than a
hand-written one"

    scope "the crossings step of the curvenet pass, and the MuJoCo guest ELF at
`interactor-mujoco-sandbox-demo` with its `mj_crossings` entry"

    decision ~S"""
    Crossings are computed by MuJoCo capsule collision in a godot-sandbox guest
    ELF rather than a bespoke compute-rd kernel. Each stroke is one freejointed
    body of capsules of radius half the proximity, and a contact between capsules
    of different strokes is a crossing at the contact midpoint. The host calls
    `mj_crossings(points, counts, proximity)`, which builds the model, collides,
    coalesces nearby contacts and returns the crossing points. This reuses the
    engine's collision the way CASSIE does, so RFD 2265's compute-rd kernel list
    drops crossings. The pass runs on the CPU sandbox guest, so the RFD 2269
    interval gate does not govern it; the gate is a golden fixture cross-checked
    against the CASSIE finder. Detail is in DETAILS.md.
    """

    problem ~S"""
    RFD 2265 listed the segment-pair crossings among the geometric kernels to
    port to compute-rd. CASSIE detects crossings through the engine's collision,
    and the workspace already carries a MuJoCo guest, so a hand-written segment
    kernel would reimplement a solved capsule collision and carry its own
    broad-phase. Reusing MuJoCo is less code and a test that is already correct.
    """

    related ~S"""
    - RFD 2265 (curvenet on compute-rd) lists crossings as a compute-rd kernel;
      this RFD moves that one step to the MuJoCo guest, and the rest stands.
    - RFD 2263 (the Skateboard's simulator gate) is the loop this feeds.
    - RFD 2269 (the interval parity gate) governs the GPU kernels. It does not
      govern this pass, which is a single CPU engine.
    """

    details_title "Curvenet crossings via the MuJoCo guest"

    details "Why the engine's collision", ~S"""
    CASSIE neatens a sketch into a curve network by detecting where a new stroke
    passes within a proximity of an existing one and splitting both at that
    point. Its own implementation reads those candidates from the engine's
    colliders rather than solving segment intersections by hand. The workspace
    already builds a MuJoCo guest ELF, so the same move is open here. A capsule of
    radius half the proximity around each stroke segment turns "within the
    proximity" into "the capsules touch", and the contact the solver returns is
    the crossing, at the midpoint between the two geoms.
    """

    details "The encoding", ~S"""
    Each stroke becomes one body with a free joint, holding a chain of capsule
    geoms along its segments. Gravity is off and the model is only brought to a
    pose, never stepped. A free joint per stroke is load-bearing: two jointless
    bodies are both welded to the world and share one weld id, and MuJoCo filters
    a pair that shares a weld id, so jointless strokes report no contacts. With a
    free joint each stroke is its own weld and inter-stroke capsules collide. A
    contact whose two geoms belong to different strokes is a crossing, and
    contacts within a small epsilon of an earlier one are the same crossing
    coalesced, so a finely tessellated stroke counts a crossing once rather than
    once per touching segment pair.
    """

    details "The gate", ~S"""
    The gate is a golden fixture rather than the RFD 2269 interval gate, because a
    single CPU engine has no second implementation to bracket against. It runs
    CASSIE's crossing_split fixture, three overshooting strokes whose three
    pairwise crossings are the nine-node topology that check already asserts, and
    confirms `mj_crossings` finds all three at the analytic intersection points,
    with a negative control that moves a stroke away so a crossing drops. The
    guest is emulated RISC-V, so the result is byte-reproducible across hosts. A
    failed model load is a failure, never a skip.
    """

    details "What is left", ~S"""
    The crossings are computed and gated, but not yet fed into the live graph.
    The curvenet guest computes its crossings inside its stroke-commit call and
    exposes no entry that returns the raw strokes or accepts crossings from
    outside, so the production feed needs one of two shapes: a curvenet entry that
    takes injected crossings, or a stage that runs both guests and joins them.
    That choice is the open step. The host already holds two sandboxes at once, so
    neither is blocked on the runtime.
    """
  end
end
