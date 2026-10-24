# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2210, "atelier shipping surface", :discussion do
  feature "the atelier ships as one native Godot binary per platform;
one runtime, two heads (interactive + headless capture)"
  scope "`entities-godot` master at precision=double with the godot-sandbox addon,
`2-contract/ggml` and `2-contract/ggml-rd`, L2 fanout at RFD66606-2214/2215/2216"

  prose ~S"""
  :: decision
  One runtime, one binary per platform (macOS / Windows / Linux): base
  Godot built with double precision and the godot-sandbox addon (
  RFD66606-2287). Vulkan renderer (MoltenVK on macOS). Two heads: interactive
  window for the Starforged VN game, headless `godot --headless
  --write-movie` for the marketing video. Same `.tscn` / `.tres`
  assets, same binary, different invocation flag. ggml consumers run,
  by agreement, as godot-sandbox guests on ggml-rd with compute-rd (
  RFD66606-2290).
  Three.js is blocklisted (RFD66606-2216). SQLite + ZSTD is the model
  bundle format on local disk (RFD66606-2214). Video muxed through
  CineForm per RFD66606-1123.
  :: related
  - [RFD66606-2287](../2287-the-first-rung-draw-and-wear-it-in-a-headset/),
    base Godot at double with the addon.
  - [RFD66606-2214](../2214-model-bundle-sqlite-range-fetch-zstd/), model
    bundle format.
  - [RFD66606-2215](../2215-one-binary-two-heads/), two-heads shape.
  - [RFD66606-2216](../2216-threejs-blocklist/), three.js blocklist.
  - [RFD66606-2229](../2229-interchangeable-parts-consolidation/),
    consolidation policy.
  - [RFD66606-2290](../2290-trim-the-independent-ggml-runtimes/), ggml
    only in guests.
  - RFD66606-2205 (Taskweft in Bao), RFD66606-2206 (video-call VRM portrait),
    RFD66606-2207 (Nord palette), RFD66606-2188 (one ggml across workspace),
    RFD66606-1123 (CineForm in Godot), RFD66606-1170 (presence loop).
  """
end
