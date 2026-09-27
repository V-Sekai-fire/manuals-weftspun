# SPDX-License-Identifier: MIT
# Copyright (c) 2026 K. S. Ernest (iFire) Lee
#
# GENERATED. Do not edit by hand.
# The taskweft planner derived this from domain.ex + rung3_garment.ex: the full
# Skateboard deliverable, six steps the solver ordered from the guards alone.
defmodule SkateboardRung3GarmentPlan do
  @source "skateboard_rung3_garment"
  @solved_by "taskweft v0.5.4"
  @temporally_consistent true
  @total_duration "PT42M"
  @plan [["a_curvenet"], ["a_mesh"], ["a_repair"], ["a_close"], ["a_drape"], ["a_deliver"]]

  def plan, do: @plan
  def source, do: @source
end
