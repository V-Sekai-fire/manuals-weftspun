# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2432, "a module ships as a plain Docker image around the shared native binary", :discussion do
  flight_level :l2
  scope "how a module is packaged as a Docker image."

  prose ~S"""
  :: hook
  A module ships as a plain Docker image that wraps the one shared native Godot binary.
  :: intrigue
  What does one image hold when the weights arrive at build time and the card is 24 GB?
  :: exit
  Check a new image against RFD66606-1036: plain Docker, `/health` + `/predict`, weights at
  build time, a two-stage Dockerfile and one model per image.
  :: decision
  - Per RFD66606-1036 (`committed`): plain Docker, `/health` + `/predict`, weights at build time,
    two-stage Dockerfile (`contract` + `worker`), one model per image.
  - The container's inference binary is the shared native Godot binary from
    &{repo("entities-godot-sandbox", planned: "4-entities")} (RFD66606-2210) with the per-model
    adapter mounted. The runtime is
    ggml with the Vulkan backend per RFD66606-2231's substitute (Vulkan on native).
  :: related
  - RFD66606-1102, where this rule lived before the split.
  - RFD66606-1036, the plain Docker packaging.
  - RFD66606-2210, the shared native Godot binary.
  - RFD66606-2231, the Vulkan substitute.
  """

  details_title "a module ships as a plain Docker image around the shared native binary"

  prose ~S"""
  :: details Target card
  Target 24 GB card (local desktop GPU per CLAUDE.md).
  """
end
