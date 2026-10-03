# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2238-g1-sim-to-real-environment.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2238 do
  use Taskweft.DSL

  @name "rfd_2238"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2238": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2238": 0}}
  }

  @todo_list [
    ["prepare", "2238"],
    ["land", "2238"]
  ]
end
