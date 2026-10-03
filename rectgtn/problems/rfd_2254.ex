# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2254-order-independent-transparency-for-cad.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2254 do
  use Taskweft.DSL

  @name "rfd_2254"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2254": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2254": 0}}
  }

  @todo_list [
    ["prepare", "2254"],
    ["land", "2254"]
  ]
end
