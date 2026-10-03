# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2274-curvenet-crossings-via-mujoco-guest.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2274 do
  use Taskweft.DSL

  @name "rfd_2274"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2274": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2274": 1}}
  }

  @todo_list [
    ["prepare", "2274"],
    ["land", "2274"]
  ]
end
