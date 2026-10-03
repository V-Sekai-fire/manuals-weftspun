# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2232-rfd-dsl-in-elixir.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2232 do
  use Taskweft.DSL

  @name "rfd_2232"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2232": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2232": 0}}
  }

  @todo_list [
    ["prepare", "2232"],
    ["land", "2232"]
  ]
end
