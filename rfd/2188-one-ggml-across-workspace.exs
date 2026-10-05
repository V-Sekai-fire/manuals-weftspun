# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2188, "One GGML across the workspace", :discussion do
  feature "a single canonical GGML source tree the whole workspace consumes"
  scope "every C/C++ project in `3-interactor` that links a tensor runtime"

  prose ~S"""
  :: decision
  &{repo("ggml")} is the one canonical GGML source in this workspace.
  Every consumer references it through the manifest; vendored copies
  are deleted; a prek gate refuses any new consumer that brings its own.

  The manifest tracks the checkout's default branch, which carries the
  consolidated tip and its 14+ custom backends.

  Placed on the contract side: the tensor runtime is a contract every
  interactor consumes. There is no `0-shared` hexagon side.
  :: problem
  Six divergent ggml copies drifted apart, two of them under one project
  name with conflicting SHAs in the manifest. One canonical tree, one
  manifest row for it and a gate that refuses a second copy stop the
  drift; RFD 2290 moves the consumers onto it. DETAILS.md carries the
  Metal coverage the canonical tree took over.
  :: related
  RFD 1000 (hexagon-side placement rule), RFD 1102 (task catalog
  gacha pipeline consumes ggml through skin-tokens.cpp and
  motion-bricks.cpp), CLAUDE.md's ggml/GGUF blocklist row (the vendor's
  own runtime is exempt; this RFD is that exemption's canonical form).
  """

  details_title "One GGML across the workspace"

  prose ~S"""
  :: details The canonical tree
  &{repo("ggml")} carries the newest independent ggml history found in the
  workspace and the widest backend surface: Vulkan, Metal, CUDA, CoreML,
  HIP, SYCL, CANN, OpenVINO, Hexagon, OpenCL, MUSA, WebGPU, BLAS, RPC,
  ZenDNN and ZDNN. Its history is not upstream material. An
  upstream-tracking branch beside the default one holds the base for a
  rebase. The ggml that llama.cpp embeds lives under that project's own git
  and is not a candidate for the canonical tree.
  :: details Metal coverage carried from the SAM3 branch
  Four Metal intents came from the SAM3 branch of an earlier copy.

  | intent | verdict | evidence |
  |---|---|---|
  | conv\_transpose\_2d on Metal | covered | the canonical tree has the same (f32\_f32, f16\_f32) template pair in `ggml-metal.metal`, with a threadgroup shared-sum reduction; surface and dtype coverage match |
  | depthwise conv\_2d (CONV\_2D\_DW) | covered with more | kernel\_conv\_2d\_dw is templated over TK (_f32\_f32, _f16\_f32) plus a tiled variant; the SAM3 kernel\_conv\_2d\_dw\_f32 is a strict subset |
  | flash\_attn\_ext K/V type check | covered | the same assertion `op->src[1]->type == op->src[2]->type` in `ggml-metal-ops.cpp` |
  | WIN\_PART / WIN\_UNPART on Metal | missing, deferred | the canonical tree has these ops only in the CPU backend (`ggml-cpu.c`). No consumer uses SAM3-style windowed attention, the CPU fallback is correct, and the Metal port waits for a consumer |

  Metal flash\_attn\_ext takes head\_dim 16 and 56: 16 template instantiations
  (dk16, dk56 × 8 K/V dtypes) and 2 entries in the head-size whitelist in
  supports_op. Vec templates are omitted because
  `ggml_metal_op_flash_attn_ext_use_vec` gates on `ne00 % 32 == 0`, which
  excludes 16 and 56.

  Verified on Apple M2 Pro. `test-backend-ops`'s default FLASH\_ATTN\_EXT
  generator loops hsk over `{ 40, 64, 72, 80, 96, 128, 192, 256, 320, 512,
  576 }`, no 16 and no 56. With 16 added test cases enumerating hsk=16 and
  hsk=56 across all 8 K/V dtypes and `-b MTL0`, 4768 of 4768 tests pass
  against the CPU reference (baseline 4752 + 16 new), and the Metal pipeline
  compile log shows the new kernels reached:
  `kernel_flash_attn_ext_{f16,f32,bf16}_dk{16,56}_dv{16,56}`. Wall clock 49 s.
  :: details The consumers
  RFD 2290 names the rows that carry ggml and trims the ones that carried a
  runtime of their own. The ggml under llama.cpp is the vendor's runtime and
  stays exempt (CLAUDE.md's ggml row). `scripts/check_ggml_singleton.py`
  refuses a `ggml.h` or `ggml.c` outside the canonical path and the exempt
  llama.cpp trees, with a planted copy as its negative control.
  """
end
