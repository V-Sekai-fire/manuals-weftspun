# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2267-persona-npcs-in-ported-scenes.exs
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
