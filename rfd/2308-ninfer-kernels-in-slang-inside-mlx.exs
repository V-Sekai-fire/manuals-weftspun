# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2308, "ninfer kernels in Slang inside MLX", :prediscussion do
  flight_level :l2
  feature "the ninfer engine runs on the Mac's GPU, its kernels written in Slang, lowered to Metal
and dispatched inside MLX"
  scope "the ninfer-all fork, lean-slang, the Bonsai 2 27B ternary `.ninfer` artifact and the
CUDA engine on the Windows desk as the parity reference"

  prose ~S"""
  :: decision
  The ninfer engine reaches the Mac by writing its kernels in Slang and running
  them inside MLX. A kernel is authored in Lean through lean-slang where the AST
  carries it, and in Slang directly where it does not yet. `slangc -target
  metal` lowers it and MLX dispatches it beside its own array ops. The port
  climbs rungs, smallest working system first: an FP32 oracle over the
  `.ninfer` artifact, then the ternary GEMV, and a full decode only after each
  op under it passes against the oracle. Weights stay in their stored dtype.
  Attention-like kernels pass on cosine above 0.999 and relative L2, not on
  per-element maximum error. Nothing on the Mac is measured, so this RFD makes
  no speed claim (operator, 2026-10-10: "port cuda to shader-slang and then
  into mlx").
  :: problem
  ninfer-all builds only for CUDA and has no Metal or CPU backend. Its
  kernels are about 498 `.cu` files using warp shuffles, `cp.async`,
  `mma.sync` and cuBLAS. The Mac converts Ternary Bonsai 2 27B into a v3
  `.ninfer` artifact, and nothing on it can serve that artifact.
  :: related
  - RFD66606-2032, Lean kernels lowered through lean-slang; RFD66606-2044, Lean at build
    time behind a flat C ABI.
  - RFD66606-2188 and RFD66606-2290, one ggml and ggml only in guests.
  """

  details_title "ninfer kernels in Slang inside MLX"

  prose ~S"""
  :: details The options
  - **Hand-port CUDA to Metal Shading Language.** Each kernel is rewritten once
    for one target. The CUDA tree is the only spec, so the copies drift, and
    no Lean source holds the kernel.
  - **Kernels in Slang, from Lean where practical, inside MLX.** Chosen. One
    kernel source lowers to Metal, SPIR-V and a CPU library, which the
    allowlist's shader-compilation row already names, and Lean authoring is
    the RFD66606-2032 shape. MLX holds the buffers, supplies its built-in ops for
    work not yet ported, and gives a Python harness the oracle runs in.
  - **MLX built-in ops, with a custom kernel only for the ternary matmul.**
    This reaches a first decode with the fewest kernels. It writes a second
    engine from MLX ops and leaves every other kernel outside Slang and Lean.
  - **ggml with its Metal backend.** ggml has no `t2_g128_fp16` format and no
    `.ninfer` reader. RFD66606-2290 keeps ggml in guests, and the allowlist names
    its Vulkan backend.

  The chosen option has costs, and each one is a rung's precondition:

  - Slang's Metal target sees less use than its SPIR-V target. Wave ops,
    `half`, bit packing and simdgroup matrices are checked per kernel, by
    reading the emitted Metal and by the oracle.
  - `mx.fast.metal_kernel` takes the body of a function and generates the
    signature itself. `slangc` emits a whole `[[kernel]]` function with its
    own buffer bindings. Either a build step rewrites the emitted entry point
    into a body, or a C++ custom primitive loads the `.metallib`. C++ is
    legacy only here, so the rewrite is tried first.
  - lean-slang's compile check links the Linux x86-64 Slang SDK only. On the
    Mac, Lean emits Slang source and the `slangc` binary compiles it, until
    the check links the macOS SDK.
  - MLX is not on the allowlist yet. It is MIT-licensed and needs a row
    before rung 1 runs.

  :: details Slang on the Mac
  Found on 2026-10-10, on the M2 Pro:

  - conda-forge carries `shader-slang` 2026.14 for `osx-arm64`, and the
    upstream release 2026.19 ships `macos-aarch64` archives.
  - A `slangc` 2026.13 arm64 binary is on the desk. A 2-bit ternary GEMV
    probe compiles with `-target metal` to Metal source, where
    `WaveActiveSum` lowers to `simd_sum`, and with `-target metallib` to a
    Metal library. `xcrun metal` compiles the emitted source.
  - The probe was not dispatched and no output was compared. MLX 0.32.0 is
    on conda-forge for `osx-arm64`.
  - The pure-Python converter ran on the M2 Pro in the pixi `osx-arm64`
    environment with `--device cpu`. It wrote `bonsai2-27b-heretic.ninfer`,
    9,520,051,456 bytes. The rung 0 oracle is what reads it back.

  :: details The rungs
  Each rung names its witness. Every gate carries a negative control that
  must fail, and an unmet precondition is a FAIL, never a skip.

  0. **Oracle.** A NumPy FP32/FP64 program reads the `.ninfer` artifact,
     decodes `t2_g128_fp16` codes with their stored FP16 scales on its own,
     and runs one decoder layer on fixed inputs. Witness: a hand-computed
     small case, and agreement with the artifact's own decoder on every
     tensor it reads. Controls: a flipped ternary code and a swapped scale
     row each fail.
  1. **Ternary GEMV.** The `t2_g128_fp16` GEMV in Slang, lowered to Metal and
     dispatched in MLX. Witness: a normwise bound with a gross pointwise cap
     against the oracle at every real layer shape and at the group boundary.
     Controls: a kernel reading the wrong group's scale, and one mapping code
     2 to 0, each fail.
  2. **Layer ops.** RMSNorm, RoPE and SwiGLU against a pointwise bound; then
     the Gated DeltaNet decode step against a stateful oracle that checks
     both output and new state; then gated full-attention decode with its KV
     cache, on cosine above 0.999 and relative L2.
  3. **Text decode.** One request, greedy, end to end. Witness: per-step
     logits against the CUDA engine on the Windows desk's 4090, on cosine and
     relative L2, and the greedy token sequence. The desk being unreachable
     is a FAIL for this rung.
  4. **Later rungs.** The vision tower, the MTP head, the DFlash2 head, then
     batching. Each one is a rung with its own oracle.

  :: details Where the code lives
  This is open. ninfer-all's own rules say a new execution platform needs an
  explicit product change, so a directory in the fork is a product change to
  a fork of somebody else's engine. A new repository fits the hexagon, but
  the workspace's one-repo-per-model rule is about models, not platforms. The
  fork itself is not placed in the goal manifest, and placement comes with
  either answer.

  :: details Open questions
  - A new repository, or a directory in the ninfer-all fork.
  - The MLX allowlist row, and whether its custom primitive or the rewritten
    entry point carries the dispatch.
  - When lean-slang's compile check links the macOS Slang SDK.
  - The Windows desk's tailnet key, which rung 3 needs.
  """
end
