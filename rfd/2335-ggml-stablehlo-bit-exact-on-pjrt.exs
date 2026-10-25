# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2335, "ggml graphs as StableHLO on PJRT, bit-exact against ggml-cpu", :discussion do
  feature "a second, out-of-guest path for scale: our own StableHLO from a ggml graph, on PJRT"

  scope "the ggml-stablehlo contract repository and the hosts that run its PJRT plugins"

  prose ~S"""
  :: decision
  - Guests stay on ggml-rd. ggml-stablehlo is a second path, outside the guest, for scale
    (operator, 2026-10-25).
  - The artifact is StableHLO that we emit from the ggml graph. No tensor-expression layer and
    no vendor plugin for the desk's GPU sits between them. IREE is blocklisted (operator,
    2026-10-25).
  - Lean 4 first: the op table, the StableHLO types in a library of their own, the emitter and
    the PJRT runner. C only where a C ABI is unavoidable: the ggml backend and the PJRT C API.
  - The pass bar is bit equality with ggml-cpu, op by op, with no tolerance. An op whose order
    differs is lowered in ggml-cpu's arm64 order. An op that is not exact is reported with its
    exact cause.
  - On the CPU, only per-op unit tests and their controls run, through the PJRT CPU plugin;
    graph emission is tested on the module text. Whole-graph runs need a GPU host.
  :: problem
  A ggml model that outgrows the guest needs a path to large accelerators. A lowering that
  verifies can still compute something else, and XLA may reorder or fuse float arithmetic,
  so only a byte comparison with the reference shows that the path computes what the guest
  computes.
  :: related
  - RFD66606-2294, the practices this work follows.
  """

  details_title "ggml graphs as StableHLO on PJRT, bit-exact against ggml-cpu"

  prose ~S"""
  :: details The reference
  ggml-cpu from the workspace's ggml fork, built with no Accelerate, BLAS, llamafile, KleidiAI
  or OpenMP, for armv8.2-a, with `-ffp-contract=off`. Then the f32 paths are ggml's own NEON
  loops. erff and expf come from CORE-MATH, because the platform libraries are not correctly
  rounded: over all 2^32 inputs the desk's libm differs from CORE-MATH on 3,491,866 erff and
  2,041,295 expf inputs.
  :: details What the lowering reproduces
  - mul_mat contracts `ne[0]` of both operands, in `ggml_vec_dot_f32`'s order: 4 accumulators
    of 4 NEON lanes with fused multiply-add, the pairwise lane reduction, then the tail.
  - `ne[]` runs fastest first; MLIR dimensions run slowest first. Views become explicit
    reshape, transpose and slice, or a gather when strides overlap.
  - norm sums mean and variance in double in ggml's order; softmax and SiLU use ggml's own
    vector exp line for line; GELU uses `0.5x(1+erf(x/sqrt 2))` with CORE-MATH erf.
  - Every multiply result and divisor is hidden behind a value only the runtime knows, so
    the back end cannot contract it into a later add or turn a division into a multiply.
  :: details XLA flags
  Sent as compile-option overrides, never as environment variables. Every CPU mode:
  `xla_cpu_enable_fast_math=false`, the four `xla_cpu_fast_math_honor_*=true`,
  `xla_cpu_enable_fast_min_max=false`, `xla_cpu_ftz=false`, `xla_cpu_use_xnnpack=false`,
  `xla_cpu_enable_platform_dependent_math=false`. The strict mode adds
  `xla_disable_hlo_passes=fusion,algsimp`; the fused mode keeps the default pipeline, and the
  module must be exact under both. The GPU mode: `xla_gpu_deterministic_ops=true`,
  `xla_gpu_exclude_nondeterministic_ops=true`, `xla_gpu_enable_fast_min_max=false`,
  `xla_gpu_ftz=false`, `xla_gpu_autotune_level=0`, `xla_gpu_enable_triton_gemm=false`, and
  fusion, priority fusion, multi-output fusion, horizontal loop fusion and algsimp disabled.
  :: details Measured on the desk
  The PJRT CPU plugin from the zml PJRT artifacts release of 2026-09-08,
  PJRT C API 0.114, on the arm64 desk. 25 per-op cases in Kimodo's denoiser shapes (mul_mat, add,
  repeat, mul, norm, scale, soft_max, GELU, SiLU, view, transpose, permute, concat) are
  bit-exact in both CPU modes. Each of 14 planted faults is caught by the cases that cover
  it, and planting any one of them in the lowering makes the gate exit 1. Emitted erff and
  expf equal CORE-MATH on every f32 input outside the subnormal class.
  :: details What is not exact
  PJRT's CPU client runs every execution with subnormals flushed to zero, and no option
  turns that off. Subnormal inputs and results are therefore not exact on the CPU plugin;
  the cause is the executor, not the module. A softmax whose scores span more than about 87
  has subnormal probabilities. The CUDA plugin ships for Linux only, so the first
  comparison of that class, and the first whole-graph Kimodo run, wait for a Linux arm64
  GPU host.
  """
end
