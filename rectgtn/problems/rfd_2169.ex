# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2169-abandon-strangler-fig-studio-core.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2169 do
  use Taskweft.DSL

  @name "rfd_2169"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2169": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2169": 0}}
  }

  @todo_list [
    ["prepare", "2169"],
    ["land", "2169"]
  ]
end
