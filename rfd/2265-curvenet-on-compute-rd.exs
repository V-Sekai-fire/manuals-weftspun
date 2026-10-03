# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2265, "Curvenet on compute-rd", :discussion do
  flight_level :l1
  feature "the pen-meshing loop holds 90Hz with headroom on the standalone
headset, by moving the curve-network off the main thread onto the GPU"
  scope "the curvenet guest at `3-interactor/curvenet/guest/curvenet`,
reimplemented on compute-rd with Lean-authored kernels"

  prose ~S"""
  :: decision
  Reimplement the CASSIE curve-network (Yu et al., doi
  10.1145/3411764.3445158) on compute-rd, kernels authored in Lean and
  lowered through Slang to SPIR-V, dispatched by an rdc::Device driver
  shaped like the avbd one. The CPU curvenet.elf stays as the oracle and a
  parity gate in `interactor-curvenet` holds both paths to the same integer
  counts and brackets every float output in the interval oracle's bounds
  (RFD 2269). Detail is in DETAILS.md.
  :: problem
  Measured on the standalone headset at 2160 by 2160 per eye against a 90Hz
  budget of 11.1 milliseconds a frame, the pen loop spends 13.8 milliseconds
  on the CPU and 9.9 on the GPU, so the compositor drops it to 72Hz with no
  headroom for what a person draws. The GPU sits under budget; the main thread
  does not, and the cost there is the curve-network in the godot-sandbox guest
  evaluated every frame. A loop that cannot hold 90Hz with slack is not
  shippable, and user-generated content only widens the gap.
  :: related
  - RFD 2234 (the dress-on pipeline) is where curvenet runs today, on the CPU.
  - RFD 2263 (the first testable release's simulator gate) is the loop this keeps at 90Hz.
  - RFD 2264 (mesh repair by voxel remesh) is the pipeline step downstream.
  - RFD 2188 (ggml on compute-rd) is the precedent for a guest dispatching
    RenderingDevice compute.
  - RFD 2274 (crossings via the MuJoCo guest) takes the segment-pair crossings
    step, so it is not among the compute-rd kernels below.
  """

  details_title "Curvenet on compute-rd"

  prose ~S"""
  :: details Two stages
  The geometric passes land first, because their per-curve kernels are already
  Lean-authored and their SPIR-V already compiles: body snap, per-edge curve
  fit, the Wahba solve per knot, the outward-sign reduction, the weld and the
  nearest-patch test. The segment-pair crossings are not among them; they run
  on the MuJoCo guest's collision (RFD 2274).

  The combinatorial core follows as the harder work: find_cycles as parallel
  edge and face enumeration with a GPU cycle basis that keeps the canonical
  sorted-edge-id order, and the minimum-weight triangulation as a GPU dynamic
  program over each boundary.
  :: details Frame budget and the async split
  The 90Hz deadline is 11.1 milliseconds. The main thread holds to 6.5 to 7.5
  of it and the GPU, compute plus render, to 8.5, which leaves about 3.5 for
  the compositor and thermal headroom. The panel runs up to 144Hz, so the
  stretch targets are 120Hz at 8.33 milliseconds, asking 4.5 to 5 on the main
  thread and 6 on the GPU, and 144Hz at 6.94 milliseconds, which leaves almost
  nothing to spare and is a headroom goal rather than a bar. Today the loop
  spends 13.8 on the main thread, so even 90Hz is met only by taking the
  curve-network off it.

  Input and solve are decoupled. The pen renders a locally predicted polyline
  on the main thread every frame, so drawing stays responsive inside a 12 to
  18 millisecond motion-to-photon window. The curve-network solve runs on
  compute-rd and is allowed one to two frames; its reconciled topology blends
  into the stroke mesh when it returns.

  The headset has unified memory, so the guest buffers back the compute
  storage buffers with no host copy. Frame N samples input, draws the
  predicted polyline and dispatches the kernel; frame N+1 or N+2 reads the
  result back without a wait and blends it in. A timeline gate bounds the
  dispatch: past about 18 milliseconds on a dense multi-stroke intersection
  the frame drops it and reuses the predicted points, so the render thread
  never blocks.
  :: details Derived spikes
  Each is measured on the headset against the budget above.

  - Dispatch parity: one Lean kernel on compute-rd, byte-parity against the
    CPU oracle, curve_casteljau first.
  - Zero-copy: a guest buffer bound as a storage buffer, measuring the host
    copy removed on unified memory.
  - Async pipeline: dispatch on frame N, non-blocking readback on N+1 or N+2,
    measuring the main-thread stall near zero.
  - Queue gate: bound the compute by a timeline, and confirm an over-budget
    dispatch drops to the predicted points without blocking.
  - Budget instrumentation: per-stage milliseconds, main thread, compute and
    render, against 6.5 and 8.5 at 90Hz, 4.5 and 6 at 120Hz, and the 6.94
    millisecond deadline at 144Hz.
  :: details Dispatch and parity
  The rdc::Device driver follows the avbd shape: buffers carrying their
  contents, cached uniform sets, one compute list, a barrier between
  dependents, a submit without a wait, and a read a later tick.

  The parity gate runs checks.cpp through the CPU and GPU paths. It requires
  the same integer counts, and it brackets every float output in the interval
  oracle's proven bounds rather than requiring identical bits, because byte
  identity does not hold across drivers (RFD 2269). The negative controls are
  kept. A parallel cycle finder that returns the right set in the wrong
  canonical order fails it, so the order is part of the contract, along with
  the index tie-break on sorts, the fixed seeds and the lowest-index-wins
  weld.
  """
end
