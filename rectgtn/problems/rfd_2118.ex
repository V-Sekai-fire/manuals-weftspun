# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2118-a-baker-replaces-the-godot-editor.exs
defmodule Rfd2118 do
  use Taskweft.DSL

  @name "rfd_2118"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2118": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2118": 0}}
  }

  @todo_list [
    ["prepare", "2118"],
    ["land", "2118"]
  ]
end
