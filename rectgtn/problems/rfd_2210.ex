# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2210-atelier-godot-web-shipping-surface.exs
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
