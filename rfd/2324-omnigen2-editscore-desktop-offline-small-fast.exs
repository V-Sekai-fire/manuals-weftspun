# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2324, "The OmniGen2 EditScore desktop build is offline, small and fast", :discussion do
  flight_level :l1

  feature "the OmniGen2 EditScore desktop downloads carry their own weights, then shrink and
speed up one gated rung at a time"

  scope "the desktop folder of our OmniGen2 fork, its package model repository and the static
download Space"

  prose ~S"""
  :: decision
  Each OmniGen2 EditScore desktop package carries its weights and never connects to a network
  (operator, 2026-10-18). The weights then shrink and the edit gets faster, one rung at a time,
  each shipped only when its quality gate passes:

  - Rung 1 stores the weights in BF16, the type the program already runs: 14.7 GiB.
  - Rung 2 merges the EditScore LoRA (low-rank adapter), then quantizes to 4 bits.
  - Rung 3 distils the two guidance passes: one transformer pass per step, not three.
  - Rung 4 distils 50 steps down to between 4 and 8.
  - Rung 5, only if size still matters: quantization-aware training to 2 bits or less.

  The Space is a static page of downloads and never edits (operator, 2026-10-18).
  :: problem
  The first packages fetched 29.1 GiB of FP32 weights on first start, so they did not work
  offline. Each edit is 50 steps of three transformer passes: two minutes on a 24 GiB desk card,
  42 minutes on a 32 GiB unified-memory machine that pages to disk. Nobody publishes a quantized
  build of the EditScore-tuned editor, and the public 4-bit file of the base model is only a
  quarter smaller than BF16.
  :: related
  - RFD66606-1144 (image-to-OmniGen2 loop) measured NF4; RFD66606-1147 (EditScore costs) scores.
  - RFD66606-2186 (abandoned QAFT plan): a BF16 LoRA over a 4-bit base is blocklisted.
  - RFD66606-2294 (agent practices): desktop builds ship from a model repository.
  """

  details_title "The OmniGen2 EditScore desktop build is offline, small and fast"

  prose ~S"""
  :: details Sources
  Drafted on 2026-10-18 from the weights repository's file list at the pinned revision,
  the program's load and edit code, a survey of the public model hub on the same day,
  and the package tests recorded on the download Space.

  :: details What the weights and the program hold today
  - Transformer: 14.78 GiB in FP32, about 3.97 billion weights.
  - Multimodal language model that reads the image and the instruction: 13.99 GiB in
    FP32, about 3.75 billion weights.
  - VAE: 0.31 GiB. EditScore LoRA: 78 MiB, kept as a separate file.

  The program loads every part with `torch_dtype=bfloat16` and applies the LoRA
  unmerged. It samples with text guidance 5.0 and image guidance 2.0 over the whole
  schedule, so each step runs the transformer three times: with the instruction,
  without it, and without the instruction or the image.

  :: details What the public hub holds
  Surveyed 2026-10-18 by base-model links and by name. Every quantized build found is
  the base model without the EditScore LoRA:

  - An FP16 repack for a node-graph front end: 7.39 GiB transformer, 6.99 GiB language
    model.
  - A GGUF set from 2 to 8 bits. Its Q4_K_M transformer is 5.57 GiB against 7.39 GiB
    at BF16: the layers whose input width is 2520 stay unquantized, because 2520 is not
    a multiple of the 32- or 256-wide blocks.
  - A lossless 11-bit entropy coding of each part, about 5 GiB for the transformer, on
    NVIDIA cards only.

  No quantized build of the EditScore scorer models was found either.

  :: details Rung 1: the weights travel in the package
  Store the transformer and the language model in BF16, keep the LoRA file, put `w/`
  inside each of the three packages and remove `--download-weights`. The program
  already casts to BF16 on load, so the stored tensors equal the ones it runs.

  - Byte identity cannot gate it: the same package, weights and seed on the same card
    gave a different PNG on each of seven runs, in two close variants.
  - Gate: the BF16 edits differ from the FP32 edits by no more than the FP32 edits
    differ from each other. Measured on a 24 GiB card, mean absolute difference over
    255 levels: FP32 against FP32 0.37 to 0.42 within a variant and 1.58 to 1.61
    across; BF16 against FP32 0.36 to 0.45 within and 1.53 to 1.62 across.
  - Control: the same edit without the LoRA differs by 26.2 to 26.4, so the check sees
    a real change.
  - Offline gate: the package edits with networking off on Windows and in Linux.
    Control: the current package without `w/` fails the same run.

  :: details Rung 2: merge, then 4 bits
  Merge the LoRA into the BF16 transformer first, then quantize; never a BF16 LoRA over
  a quantized base. The width 2520 is 2^3 x 3^2 x 5 x 7, so either layout below
  quantizes it, and the first step measures both on each backend:

  - groups that divide 2520 (40 or 56 weights), read by a small linear layer that
    dequantizes as it runs, on CUDA, Metal and CPU alike;
  - zero padding of each input width to 2560, which leaves the output unchanged and
    lets standard 4-bit block formats apply.

  Go up a ladder, never all at once: the language model first, then the transformer
  four blocks at a time. A layer that fails the gate stays at 8 bits. The VAE stays
  BF16.

  :: details The quality gate for rungs 2 to 5
  - Inputs: 64 real photographs from the license-filtered COCO train2017 people set,
    never the blinded val2017 holdout, each paired with an instruction from held-out
    shard 90 of our EditScore training corpus. Seeds fixed per pair.
  - Reference: the rung 1 output for each pair.
  - Measure: both EditScore axes for every output (RFD66606-1147), and the perceptual
    distance to the reference.
  - Baseline: the reference model run again with a second seed. The seed-to-seed
    spread is the floor.
  - Pass: the paired mean drop on each EditScore axis is inside that spread.
  - Control: plain 2-bit rounding of every layer, with no calibration, must fail.

  :: details Rungs 3 and 4: fewer passes, fewer steps
  The rung 2 BF16 merge is the teacher. Rung 3 trains the student to give the guided
  result in one pass. Rung 4 trains it to reach the 50-step result in 4 to 8 steps.
  Each student goes back through rung 2 before it ships. Training runs on owned desk
  GPUs. Its targets are teacher outputs, so they are generated synthetic data: each
  carries the teacher checkpoint, instruction and seed, and is stored apart from real
  data. Training inputs come from training shards, never shard 90.

  :: details Rung 5: below 4 bits
  Only if size still matters after rung 2. Quantization-aware training quantizes in
  every forward pass with a straight-through backward pass and saves one checkpoint.
  Losses: matching the BF16 teacher's output on corpus inputs at random noise levels,
  plus the flow loss on corpus edits that score 22 or more on both axes. It climbs the
  same ladder as rung 2, a few layers per rung.

  :: details What is not known
  - How fast that machine edits once the model fits in memory: its GPU does roughly a
    tenth of the desk card's arithmetic, which suggests about 20 minutes per edit at
    rung 2. The rung 2 run measures it.
  - Whether 4 bits holds the gate, and which layout is faster on each backend.
  - How few steps keep the gate in rung 4.
  - Whether a rung 5 model passes the gate at all.
  """
end
