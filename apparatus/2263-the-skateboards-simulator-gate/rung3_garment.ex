# SPDX-License-Identifier: MIT
# Copyright (c) 2026 K. S. Ernest (iFire) Lee
#
# Ladder rung 3: the draped garment a person gets back. Adds cloth by
# vertex block descent (RFD 2249) and delivery on top of rung 2. This is
# the full Skateboard deliverable, the validate rung of the ladder.
defmodule SkateboardRung3Garment do
  use Taskweft.DSL

  @name "skateboard_rung3_garment"
  @source "skateboard_simulator_gate"

  @variables %{have: %{type: :bool, init: %{strokes: true}}}

  @todo_list [%{goal: [%{pointer: "/have/garment", eq: true}]}]
end
