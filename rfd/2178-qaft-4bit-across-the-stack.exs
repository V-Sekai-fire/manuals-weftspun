# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2178, "QAFT 4-bit across the model stack", :discussion do
  feature "target every model in the atelier-workshop at 4-bit\nQuantization-Aware Fine-Tuning"
  scope "every model row in RFD66606-1102's task catalog"

  prose ~S"""
  :: decision
  Every model in the atelier-workshop (the pipeline) targets QAFT 4-bit; three classes (A
  upstream available, B feasible locally, C infeasible locally) track where each stands.
  :: problem
  RFD66606-1027 (QAFT-first weights) committed QAFT-first as the default weights format.
  RFD66606-2139 (QAFT stack survey, abandoned) found only Gemma-4-12B ships a true upstream QAT
  Q4_0 release. Wan-VACE, Pixal3D, VoxHammer, MoGe-3, and the audio-panel models run at published
  precision. The plan needs a per-model position: which model is QAFT'd, when, at what compute
  cost.
  :: section The three classes
  - Class A (upstream QAFT available): use verbatim. Gemma-4-12B QAT Q4_0 today.
  - Class B (upstream QAFT feasible locally): the workspace produces one from published weights
  via a QAFT fine-tune on the RTX 3090. Small models (Qwen3-TTS-1.7B, Kimodo, SkinTokens,
  MoGe-3, rf-detr-Seg, WavLM, wav2vec2, ipa-whisper) fit in one overnight run each.
  - Class C (upstream QAFT infeasible locally): Wan-VACE 14B, Pixal3D 24 GB base. QAFT needs
  multi-day runs; parked until compute expands or an upstream Q4 release lands.

  See [DETAILS.md](DETAILS.md) for the per-model class, size, and compute estimate. See
  RFD66606-1027 (QAFT-first weights) for the QAFT-first rule.
  :: related
  Extends RFD66606-1027 (QAFT-first weights, committed). Consumed by RFD66606-2167 (voice-reward
  distillation, parked, needs Class B Qwen3-TTS QAFT).
  """

  details_title "QAFT 4-bit across the model stack"

  prose ~S"""
  :: details Per-model table
  Compute estimates assume the RTX 3090 (24 GB) and a QAFT fine-tune on
  each model's own pretraining data or a distillation-appropriate
  substitute. "Fits" = QAFT run fits 24 GB VRAM. "Overnight" = <12 h.
  "Multi-day" = >36 h continuous.

  - Gemma-4-12B: params 12B; upstream qaft ✓ Q4_0 GGUF (Google); class A; qaft compute 0
    (verbatim); notes The anchor case; RFD66606-1027's canonical example.
  - Wan-VACE: params 14B; upstream qaft ✗; class C; qaft compute Multi-day, tight; notes Doesn't
    fit 24 GB in QAFT config without heavy gradient checkpointing; parked.
  - Pixal3D (image → mesh): params ~24 GB bf16; upstream qaft ✗; class C; qaft compute Multi-day,
    tight; notes Same 24 GB ceiling; staged inference already at peak; QAFT training doesn't fit.
  - VoxHammer: params 0 (no weights, RFD66606-1162); upstream qaft n/a; class n/a; qaft compute 0;
    notes Nothing to quantize.
  - TRELLIS.2: params ~8B; upstream qaft ✗; class B; qaft compute Overnight; notes Fits QAFT run
    at moderate batch.
  - MoGe-3: params ~1B; upstream qaft ✗; class B; qaft compute Hours; notes Small; trivial run.
  - SkinTokens: params ~1B; upstream qaft ✗; class B; qaft compute Hours; notes Small.
  - Kimodo: params ~0.6B; upstream qaft ✗; class B; qaft compute Hours; notes Small.
  - rf-detr-Seg: params ~0.2B; upstream qaft ✗; class B; qaft compute Hours; notes Very small.
  - LaMa (inpainting): params ~0.2B; upstream qaft ✗; class B; qaft compute Hours; notes Very
    small.
  - Qwen3-TTS-12Hz-1.7B-Base: params 1.7B; upstream qaft ✗; class B; qaft compute Overnight; notes
    Blocks RFD66606-2167's voice-reward distillation until done.
  - Voxtral Mini 3B: params 3B; upstream qaft ✗; class B; qaft compute Overnight; notes Fits
    comfortably.
  - Whisper large-v3: params 1.55B; upstream qaft ✗; class B; qaft compute Hours; notes Small.
  - Parakeet TDT 0.6B v3: params 0.6B; upstream qaft ✗; class B; qaft compute Hours; notes Small.
  - wav2vec2 large: params 0.3B; upstream qaft ✗; class B; qaft compute Hours; notes Small.
  - ipa-whisper (small + base): params ~0.5 GB; upstream qaft ✗; class B; qaft compute Hours;
    notes Small.
  - WavLM Base+ SV: params ~0.1B; upstream qaft ✗; class B; qaft compute Minutes; notes Trivial.
  - allosaurus (universal + 27): params ~0.03B; upstream qaft ✗; class B; qaft compute Minutes;
    notes Trivial; per-language head.
  :: details Sequencing
  Class-B QAFT rungs, cheapest first, so each result unblocks the next:

  1. **Voice-adjacent small models first**, Qwen3-TTS-1.7B, wav2vec2,
     Parakeet, ipa-whisper. Overnight batch. Unblocks RFD66606-2167
     (voice-reward distillation) because both the reward LoRA base and
     the TTS candidate generation stop dominating inference cost.
  2. **Segmentation + inpainting**, rf-detr-Seg, LaMa. Hours. Small
     in the compute budget; large in the RFD66606-1168 layer-decomposition
     path's per-view cost.
  3. **Motion + rigging**, Kimodo, SkinTokens, MoGe-3. Hours each.
  4. **Mid-tier vision + audio**, TRELLIS.2 (~8B), Voxtral (3B),
     Whisper large-v3. Overnight runs.
  5. **Class C (Wan-VACE, Pixal3D)**, parked. Either an upstream Q4
     lands or the workspace acquires >24 GB training capacity.
  :: details Compute cost of the plan
  Rough total for Class B (all rungs 1-4): about a week of continuous
  3090 wall-time if run serially. Roughly a weekend if parallelised
  across a Mac (MPS QLoRA for the smallest) and the 3090 (true QAFT
  for the mid-tier). CLAUDE.md's Compute constraint applies: rented
  compute stays blocklisted; runs happen on the desktop machine.
  :: details Retraction / adjustment note
  RFD66606-2139 read "no true-QAFT 4-bit checkpoints exist upstream" as
  "only Gemma runs QAFT-quantized." That reading conflated "upstream
  publishes one" with "the workspace can have one." This RFD splits
  those two into Class A vs Class B. Wan-VACE and Pixal3D stay in
  Class C, matching RFD66606-2139's concern for those specific models.
  """
end
