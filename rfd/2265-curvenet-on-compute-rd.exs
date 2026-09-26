# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2265. `mix rfd.render` renders rfd/2265-curvenet-on-compute-rd/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2265 do
  use RFD.DSL

  rfd 2265, "Curvenet on compute-rd" do
    state :discussion

    flight_level :l1

    feature "the pen-meshing loop holds 90Hz with headroom on the standalone
headset, by moving the curve-network off the main thread onto the GPU"

    scope "the curvenet guest at `3-interactor/dress-on/guest/curvenet`,
reimplemented on compute-rd with Lean-authored kernels"

    decision ~S"""
    Reimplement the CASSIE curve-network on compute-rd, kernels authored in Lean
    and lowered through Slang to SPIR-V, dispatched by an rdc::Device driver
    shaped like the avbd one. The CPU curvenet.elf stays as the oracle and a
    parity gate at `gates/4-curvenet` holds both paths to the same counts and
    the same blake3 signature. Detail is in DETAILS.md.
    """

    problem ~S"""
    Measured on the standalone headset at 2160 by 2160 per eye against a 90Hz
    budget of 11.1 milliseconds a frame, the pen loop spends 13.8 milliseconds
    on the CPU and 9.9 on the GPU, so the compositor drops it to 72Hz with no
    headroom for what a person draws. The GPU sits under budget; the main thread
    does not, and the cost there is the curve-network in the godot-sandbox guest
    evaluated every frame. A loop that cannot hold 90Hz with slack is not
    shippable, and user-generated content only widens the gap.
    """

    related ~S"""
    - RFD 2234 (the dress-on pipeline) is where curvenet runs today, on the CPU.
    - RFD 2263 (the Skateboard's simulator gate) is the loop this keeps at 90Hz.
    - RFD 2264 (mesh repair by voxel remesh) is the pipeline step downstream.
    - RFD 2188 (ggml on compute-rd) is the precedent for a guest dispatching
      RenderingDevice compute.
    """

    drafted_by :ai

    details_title "Curvenet on compute-rd"

    details "Two stages", ~S"""
    The geometric passes land first, because their per-curve kernels are already
    Lean-authored and their SPIR-V already compiles: body snap, the segment-pair
    crossings, per-edge curve fit, the Wahba solve per knot, the outward-sign
    reduction, the weld and the nearest-patch test.

    The combinatorial core follows as the harder work: find_cycles as parallel
    edge and face enumeration with a GPU cycle basis that keeps the canonical
    sorted-edge-id order, and the minimum-weight triangulation as a GPU dynamic
    program over each boundary.
    """

    details "Dispatch and parity", ~S"""
    The rdc::Device driver follows the avbd shape: buffers carrying their
    contents, cached uniform sets, one compute list, a barrier between
    dependents, a submit without a wait, and a read a later tick.

    The parity gate runs checks.cpp through the CPU and GPU paths and requires
    the same integer counts and blake3 signature, with the negative controls
    kept. A parallel cycle finder that returns the right set in the wrong
    canonical order fails it, so the order is part of the contract, along with
    the index tie-break on sorts, the fixed seeds, the lowest-index-wins weld,
    and no summation reorder that moves a reduction by one unit in the last
    place.
    """
  end
end
