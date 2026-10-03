# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2234-dress-on-pipeline.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2234 do
  use Taskweft.DSL

  @name "rfd_2234"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2234": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2234": 1}}
  }

  @todo_list [
    ["prepare", "2234"],
    ["land", "2234"]
  ]
end
