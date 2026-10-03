# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2210-atelier-godot-web-shipping-surface.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2210 do
  use Taskweft.DSL

  @name "rfd_2210"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2210": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2210": 0}}
  }

  @todo_list [
    ["prepare", "2210"],
    ["land", "2210"]
  ]
end
