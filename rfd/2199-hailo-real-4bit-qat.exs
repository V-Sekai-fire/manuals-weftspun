# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2199, "Real 4-bit QAT with Hailo as target hardware", :discussion do
  feature "real QAT loop producing int4 weights, compiled and deployed on Hailo, filling the PR #256/#257 gap"
  scope "int4 only, end-to-end training loop to Hailo HEF"

  prose ~S"""
  :: preamble
  Not active: parked 2026-09-04 and waiting on firmware. The Hailo USB was left stuck in a
  bootloader after a partial update, and the operator parked the RFD rather than forcing an
  admin recovery. Until that firmware recovers the on-device path is gated; the ViT-base BN
  backbone measured a 4.57% accuracy drop under it and the measurement fork is not
  publishable, so the on-device QAT path at this backbone is not viable. Un-park when the
  firmware is back and a publishable backbone is available. See `[[hailo-ugen300-shelved]]`
  and `logbook-rfd-2199-vit-base-bn-pick-provenance.md`.
  :: decision
  Build real 4-bit QAT infrastructure with Hailo as the deployment target. Int4 only. Int8 QAT
  is not the fallback. If Hailo hardware or the DFC toolchain does not support int4 weights,
  this RFD terminates with that finding and the operator picks the next target (different NPU
  vendor, GPU-only int4 QAT via Torchao, or wait for the field).

  Model choice deferred to the first spike. **First spike:** verify Hailo int4 support.
  **Loop:** fake-quant forward, STE backward, single quantized ckpt (Torchao
  `Int4WeightOnlyQuantizer` or custom STE). **Model priority:** small mtmd first; workspace
  target after.
  :: problem
  PR #256 blocks bnb NF4 + post-quantization fine-tuning. PR #257 blocks PTQ. The compliant
  shape has no framework support for our generative models; the only real-QAT FOSS today is
  Gemma 4 QAT (language-only). This RFD closes that gap.
  :: related
  RFD66606-2186, RFD66606-2198, PR #256, PR #257, `[[hailo-ugen300-shelved]]`.
  """
end
