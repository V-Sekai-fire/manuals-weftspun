# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2028-hexagonal-core-ports-adapters.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2028 do
  use Taskweft.DSL

  @name "rfd_2028"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2028": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2028": 0}}
  }

  @todo_list [
    ["prepare", "2028"],
    ["land", "2028"]
  ]
end
