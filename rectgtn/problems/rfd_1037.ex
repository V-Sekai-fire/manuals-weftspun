# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1037-composite-models-as-taskweft-domains.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1037 do
  use Taskweft.DSL

  @name "rfd_1037"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1037": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1037": 0}}
  }

  @todo_list [
    ["prepare", "1037"],
    ["land", "1037"]
  ]
end
