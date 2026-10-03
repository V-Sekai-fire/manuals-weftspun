# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2236-fbd-teacher-in-three-steps.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2236 do
  use Taskweft.DSL

  @name "rfd_2236"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2236": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2236": 0}}
  }

  @todo_list [
    ["prepare", "2236"],
    ["land", "2236"]
  ]
end
