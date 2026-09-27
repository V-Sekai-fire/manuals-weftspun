# SPDX-License-Identifier: MIT
# Copyright (c) 2026 K. S. Ernest (iFire) Lee
#
# GENERATED. Do not edit by hand.
# The taskweft planner derived this from domain.ex + rung2_closed_solid.ex.
defmodule SkateboardRung2ClosedSolidPlan do
  @source "skateboard_rung2_closed_solid"
  @solved_by "taskweft v0.5.4"
  @temporally_consistent true
  @total_duration "PT17M"
  @plan [["a_curvenet"], ["a_mesh"], ["a_repair"], ["a_close"]]

  def plan, do: @plan
  def source, do: @source
end
