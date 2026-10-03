# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2267-persona-npcs-in-ported-scenes.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2267 do
  use Taskweft.DSL

  @name "rfd_2267"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2267": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2267": 0}}
  }

  @todo_list [
    ["prepare", "2267"],
    ["land", "2267"]
  ]
end
