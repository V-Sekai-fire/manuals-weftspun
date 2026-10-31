# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2430, "the gacha critical path is ten rungs from a prompt to a public roll", :discussion do
  flight_level :l2
  scope "the ten rungs of the gacha path and its runtime motion source."

  prose ~S"""
  :: hook
  Ten rungs take the gacha from a language prompt to a public, hosted roll button.
  :: intrigue
  Each rung produces an output the next rung consumes, so a rung with no output leaves the next
  one nothing to take.
  :: exit
  Follow the ten rungs in order, from the language prompt to the public hosted roll page, and
  check that each consumes the output of the one before.
  :: decision
  Ten rungs, each producing an output the next rung consumes:

      0. Language prompt → image           (OmniGen2, Q4 GGUF + Flow LCM LoRA GGUF)
      1. Image → mesh                      (Pixal3D, Q4 GGUF)
      2. Mesh → judged                     (EditScore over Qwen3-VL-8B Q4 GGUF)
      3. Judged → repaired                 (VoxHammer, procedural, N-attempt bound)
      4. Repaired → skinned                (skin-tokens.cpp against ANNY, GGUF)
      5. Skinned → tagged (SAM2 or rf-detr-Seg + OmniGen2 per RFD66606-2183, all GGUF)
      6. Tagged → VRM                      (portable character)
      7. Prompt list → pool                (~50 VRMs, judged, seed-reproducible)
      8. Pool → roll button                (native Godot binary head per RFD66606-2210)
      9. Public                            (hosted with sponsor link)
  :: related
  - RFD66606-1102, where this rule lived before the split.
  - RFD66606-2183, the tagging of rung 5.
  - RFD66606-2210, the native Godot binary head of rung 8.
  - RFD66606-1028, the license class already accepted for Kimodo-SOMA-*.
  - RFD66606-2230, the shared `modules/ggml/` module.
  """

  details_title "the gacha critical path is ten rungs from a prompt to a public roll"

  prose ~S"""
  :: details Runtime motion
  Runtime motion: motion-bricks.cpp (already ggml/GGUF) generates keyframe-driven animation from
  the shipped VRM. Apache-2.0 code, NVIDIA Open Model License on weights (same license class
  already accepted for Kimodo-SOMA-* per RFD66606-1028). The model has 183M params. Runs
  alongside rungs 7-9 as
  the animation source for the pool preview and hosted roll page. Loaded through the shared
  `modules/ggml/` module per RFD66606-2230.
  """
end
