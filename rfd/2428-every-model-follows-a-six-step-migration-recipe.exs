# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2428, "every model follows a six-step migration recipe", :discussion do
  flight_level :l2
  scope "the six steps that move one model onto the shared ggml runtime."

  prose ~S"""
  :: hook
  Every model moves to the shared ggml runtime by the same six steps, one row per consumer.
  :: intrigue
  Which quantization does a vision model get? Q4_K_M only if it produces a measurable EditScore
  win over Q4_0 on held-out inputs.
  :: exit
  Follow the six steps in order for a model, starting with the Q4 quantize, and finish with its
  Docker image.
  :: decision
  - Every model follows the recipe RFD66606-2229 named as the interchangeable-parts consolidation
    shape, one row per consumer.
  - The six steps are Q4 quantize, GGUF conversion, ZSTD-SQLite bundle, the `Ggml.load_model()`
    GDExtension call, GDScript adapter, and Docker image.
  :: related
  - RFD66606-1102, where this rule lived before the split.
  - RFD66606-2229, the interchangeable-parts consolidation shape.
  - RFD66606-2214, the ZSTD-SQLite bundle shape.
  - RFD66606-2230, the `Ggml.load_model()` surface.
  - RFD66606-1036, the `/health` + `/predict` packaging shape.
  """

  details_title "every model follows a six-step migration recipe"

  prose ~S"""
  :: details Migration recipe (per model)
  Same recipe RFD66606-2229 named as the interchangeable-parts consolidation
  shape, one row per consumer:

  1. **Q4 quantize**, QAT if we train the model, PTQ per the CLAUDE.md
     Post-training-quantization blocklist exemption (a vendor's own
     runtime is exempt from the QAT-only rule) otherwise. Target Q4_0
     for text models, Q4_K_M for vision if the K-quant produces a
     measurable EditScore win over Q4_0 on held-out inputs.
  2. **GGUF conversion**, via llama.cpp's `convert_hf_to_gguf.py` for
     HF-hosted models, per-model script for non-HF checkpoints. Ports
     for `Wan-VACE`, `Pixal3D`, `MoGe-3`, `rf-detr-Seg`, `LaMa`,
     `Qwen3-TTS`, `Parakeet`, `Voxtral`, `wav2vec2`, `allosaurus`,
     `WavLM` all follow this step.
  3. **ZSTD-SQLite bundle**, RFD66606-2214 shape, `sqlite3_open()` on
     local disk. One `.zstd.sqlite` per model bundle, install-time
     download via the release channel.
  4. **`Ggml.load_model()` GDExtension call**, RFD66606-2230 surface, the
     native `modules/ggml/` module hands bytes to ggml.
  5. **GDScript adapter**, per-model `.gd` file at
     `res://adapters/<name>.gd`, extends `GgmlAdapter`, defines
     `format_prompt` / `decode_output` / `apply_lora` per model
     quirks.
  6. **Docker image**, per RFD66606-1036 `/health` + `/predict` shape
     still applies, the container binary is now the native Godot
     binary + shared `modules/ggml/` + the model's ZSTD-SQLite
     bundle + adapter `.gd`. One model per image (packaging stays
     RFD66606-1036), one runtime across images.
  """
end
