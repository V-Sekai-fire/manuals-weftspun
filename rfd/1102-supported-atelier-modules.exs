# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1102, "The supported task catalog, one live source", :committed do
  scope "RFD66606-1036 (packaging), RFD66606-1173 (pipeline), RFD66606-2136 (gacha ladder),
RFD66606-2188 (one ggml across workspace), RFD66606-2210 (atelier surface), RFD66606-2230 (ggml
adapters)"
  attest_in :none

  prose ~S"""
  :: hook
  Every atelier module runs on ggml, and one live catalog lists them.
  :: intrigue
  Wan-VACE, Pixal3D and MoGe-3 have no upstream GGUF conversion and carry "port needed".
  :: exit
  Check a new atelier module against the decision above before you merge it.
  :: decision
  Every module in the atelier catalog runs on **ggml** (RFD66606-2188). Weights ship as GGUF,
  quantised to Q4. The set of Docker images this workspace ships per RFD66606-1036 (plain HTTP,
  `/health` + `/predict`, weights at build time, one model per image) runs on the local desktop
  GPU per CLAUDE.md via ggml's Vulkan backend (RFD66606-2231's substitute), and feeds the two
  pipelines the workspace operates:

  - **MaskScore corpus construction** (RFD66606-1173): eight stubs across
    mesh/depth/pose/keypoints/multimodal/speech/text/video. Five shipped on HF (RFD66606-2164
    speech + Rung 1 walking skeleton).
  - **The gacha critical path** (RFD66606-2136): ten-rung ladder from a language prompt to a
    public roll-button-dispensed VRM.

  :: related
  RFD66606-1036 (Docker packaging), RFD66606-1053 (OpenUSD internal + glTF/VRM at edge),
  RFD66606-1027 (GPU tier), RFD66606-1173 (multimodal pipeline), RFD66606-2136 (gacha ladder),
  RFD66606-2164 (Speech stub shipped), RFD66606-2188 (one ggml across workspace), RFD66606-2210
  (atelier native shipping surface), RFD66606-2214 (model bundle SQLite+ZSTD), RFD66606-2229
  (interchangeable-parts consolidation), RFD66606-2230 (ggml adapters in godot-sandbox),
  RFD66606-2231 (Vulkan renderer).
  RFD66606-2428 to RFD66606-2434, the recipe, the two pipelines, the format boundary, the
  packaging, the backend API and the consumers, one RFD each.
  """

  details_title "The supported task catalog, one live source"

  prose ~S"""
  :: details_preamble
  Every module in the atelier catalog runs on **ggml** (RFD66606-2188:
  one ggml source across the workspace at `2-contract/ggml/`).
  Weights ship as GGUF, quantised to Q4 unless a measurement asks
  for wider precision. Consumer projects wrap the shared runtime;
  per-model adapters (tokenizer, prompt template, LoRA, sampler
  config) are GDScript files loaded under Godot's script sandbox per
  RFD66606-2230. Models with no upstream GGUF conversion carry a "port
  needed" note; RFD66606-2428 holds the six-step migration recipe.
  :: details Model catalog
  | Task                          | Model                         | Weights (Q4 target)             | Runtime                                        |
  | ----------------------------- | ----------------------------- | ------------------------------- | ---------------------------------------------- |
  | Text/image reasoning          | Gemma-4-12B (QAT Q4_0)        | ~6 GB Q4_0 GGUF                 | ggml native (llama.cpp Vulkan backend)         |
  | Reward model (image editing)  | Qwen3-VL-8B + EditScore LoRA  | ~4 GB Q4 GGUF + LoRA GGUF sidecar | ggml native; LoRA applied via `Ggml.load_lora` |
  | Text/image → image            | Wan-VACE                      | ~7 GB Q4 GGUF                   | ggml native; **port needed** (upstream is torch) |
  | Image → coarse mesh           | Pixal3D (TRELLIS.2 impl)      | ~2 GB Q4 GGUF                   | ggml native; **port needed**                   |
  | Mesh refinement               | VoxHammer                     | no weights                      | ggml native (procedural, no model file)        |
  | Image → mesh (fast)           | Pixal3D (TRELLIS.2 impl)      | same row as above               | one repo, one GGUF, one row per Pixal3D-is-TRELLIS.2 memory |
  | Metric depth                  | MoGe-3                        | ~250 MB Q4 GGUF                 | ggml native; **port needed**                   |
  | Auto-rig                      | SkinTokens                    | GGUF (skin-tokens.cpp)          | ggml native (vendor's own runtime, already GGML) |
  | Text → motion | Kimodo | GGUF (motion-bricks-cpp rev) | ggml native; see the note below |
  | Mesh segmentation | rf-detr-Seg (RFD66606-1168) | GGUF (segmentation head) | ggml native;
  **port needed** from ONNX | | Layer decomposition | rf-detr-Seg + LaMa inpainting | GGUF each |
  ggml native; **port needed** | | Mesh retopology | AutoRemesher, xatlas UV | no weights | native
  binary (format-adjacent tools) |

  Kimodo writes the SOMA-2603.16858 pose format: 77 rotation vectors, which become 78 with the
  root identity prepended.
  :: details Voice + ASR (RFD66606-2164)
  | Task                          | Model                                      | Weights (Q4 target)   | Runtime                                    |
  | ----------------------------- | ------------------------------------------ | --------------------- | ------------------------------------------ |
  | Voice cloning                 | Qwen3-TTS-12Hz-1.7B-Base                   | ~900 MB Q4 GGUF       | ggml native; **port needed**              |
  | ASR (canonical)               | Parakeet TDT 0.6B v3 (CC-BY-4.0)           | ~350 MB Q4 GGUF       | ggml native; **port needed** from Nemo    |
  | ASR panel (7 tracks)          | Parakeet TDT 0.6B v3, Voxtral Mini 3B, wav2vec2, Voxtral-IPA, Gemma-4-12B GBNF-IPA, allosaurus universal + eng | ~various Q4 GGUFs     | ggml native for each; Gemma-4-12B already GGUF; Voxtral + wav2vec2 + allosaurus **ports needed** |
  | Speaker embedding             | Microsoft WavLM Base+ SV                   | ~100 MB Q4 GGUF       | ggml native; **port needed**              |
  :: details Related
  RFD66606-1036 (Docker packaging), RFD66606-1053 (OpenUSD internal + glTF/VRM
  at edge), RFD66606-1094 (multi-image routing), RFD66606-1084 (avatar pipeline
  client side), RFD66606-1088 (HTTPS setup), RFD66606-1085 (code map), RFD66606-1105
  (webcam avatar control), RFD66606-1108 (XR floor anchoring), RFD66606-2188
  (one ggml across workspace), RFD66606-2214 (model bundle SQLite+ZSTD),
  RFD66606-2229 (interchangeable-parts consolidation policy), RFD66606-2230
  (ggml adapters in godot-sandbox), RFD66606-2210 (atelier shipping
  surface, native).
  """
end
