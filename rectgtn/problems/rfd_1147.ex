# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1147-what-editscore-costs-and-returns.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1147 do
  use Taskweft.DSL

  @name "rfd_1147"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1147": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1147": 1}}
  }

  @todo_list [
    ["prepare", "1147"],
    ["land", "1147"]
  ]
end
