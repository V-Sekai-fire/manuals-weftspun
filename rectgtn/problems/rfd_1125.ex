# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1125-two-prose-gates.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1125 do
  use Taskweft.DSL

  @name "rfd_1125"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1125": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1125": 0}}
  }

  @todo_list [
    ["prepare", "1125"],
    ["land", "1125"]
  ]
end
