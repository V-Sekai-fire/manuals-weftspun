# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2434, "consumers wrap the shared ggml runtime through a GDExtension surface", :discussion do
  flight_level :l2
  scope "how consumer projects reach the shared ggml runtime."

  prose ~S"""
  :: hook
  Consumer projects reach the shared ggml runtime through one GDExtension surface.
  :: intrigue
  Each model has its own GDScript adapter file, loaded under Godot's script sandbox, so the
  runtime itself stays shared.
  :: exit
  Check a new consumer against the rule: it wraps the shared ggml runtime of RFD66606-2188 and
  calls
  `Ggml.load_model`.
  :: decision
  Consumer projects wrap the shared ggml runtime of RFD66606-2188.
  :: related
  - RFD66606-1102, where this rule lived before the split.
  - RFD66606-2230, the native `modules/ggml/` module.
  """

  details_title "consumers wrap the shared ggml runtime through a GDExtension surface"

  prose ~S"""
  :: details The GDExtension surface
  The native `modules/ggml/` module (RFD66606-2230) exposes a GDExtension surface
  (`Ggml.load_model`, `Ggml.run_inference`, `Ggml.load_lora`) consumed by per-model GDScript
  adapter files loaded under Godot's script sandbox.
  """
end
