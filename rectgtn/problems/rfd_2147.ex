# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2147-bao-is-critical-infrastructure.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2147 do
  use Taskweft.DSL

  @name "rfd_2147"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2147": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2147": 0}}
  }

  @todo_list [
    ["prepare", "2147"],
    ["land", "2147"]
  ]
end
