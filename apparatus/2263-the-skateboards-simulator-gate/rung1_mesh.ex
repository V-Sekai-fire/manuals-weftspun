# SPDX-License-Identifier: MIT
# Copyright (c) 2026 K. S. Ernest (iFire) Lee
#
# Ladder rung 1: strokes to a mesh. This is the replay gate the
# Skateboard already reaches (RFD 2263 Phase A, merged). Shippable now.
# The todo_list names the artifact, not the steps; the planner takes the
# steps from domain.ex. We do not tell the solver the answer.
defmodule SkateboardRung1Mesh do
  use Taskweft.DSL

  @name "skateboard_rung1_mesh"
  @source "skateboard_simulator_gate"

  # Only what this rung fixes: the stroke fixture exists (skirt.usda).
  @variables %{have: %{type: :bool, init: %{strokes: true}}}

  @todo_list [%{goal: [%{pointer: "/have/mesh", eq: true}]}]
end
