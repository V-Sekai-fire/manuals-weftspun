# SPDX-License-Identifier: MIT
# Copyright (c) 2026 K. S. Ernest (iFire) Lee
#
# GENERATED. Do not edit by hand.
# The taskweft planner derived this from domain.ex + rung1_mesh.ex; the order
# was not written down anywhere, it was solved from the action guards.
defmodule SkateboardRung1MeshPlan do
  @source "skateboard_rung1_mesh"
  @solved_by "taskweft v0.5.4"
  @temporally_consistent true
  @total_duration "PT7M"
  @plan [["a_curvenet"], ["a_mesh"]]

  def plan, do: @plan
  def source, do: @source
end
