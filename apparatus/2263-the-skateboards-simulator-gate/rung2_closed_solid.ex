# SPDX-License-Identifier: MIT
# Copyright (c) 2026 K. S. Ernest (iFire) Lee
#
# Ladder rung 2: a closed solid a point-in-solid test can read. Adds mesh
# repair (RFD 2264) and the closed-solid contract (RFD 2248) on top of
# rung 1. The goal is stated; the order is the planner's to find.
defmodule SkateboardRung2ClosedSolid do
  use Taskweft.DSL

  @name "skateboard_rung2_closed_solid"
  @source "skateboard_simulator_gate"

  @variables %{have: %{type: :bool, init: %{strokes: true}}}

  @todo_list [%{goal: [%{pointer: "/have/closed_solid", eq: true}]}]
end
