# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2136-the-gacha-critical-path.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2136 do
  use Taskweft.DSL

  @name "rfd_2136"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2136": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2136": 0}}
  }

  @todo_list [
    ["prepare", "2136"],
    ["land", "2136"]
  ]
end
