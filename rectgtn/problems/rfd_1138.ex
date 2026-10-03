# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1138-where-range-of-motion-comes-from.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1138 do
  use Taskweft.DSL

  @name "rfd_1138"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1138": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1138": 0}}
  }

  @todo_list [
    ["prepare", "1138"],
    ["land", "1138"]
  ]
end
