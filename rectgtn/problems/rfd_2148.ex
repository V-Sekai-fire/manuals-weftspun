# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2148-grafcet-as-taskwefts-authoring-surface.exs
defmodule Rfd2148 do
  use Taskweft.DSL

  @name "rfd_2148"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2148": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2148": 0}}
  }

  @todo_list [
    ["prepare", "2148"],
    ["land", "2148"]
  ]
end
