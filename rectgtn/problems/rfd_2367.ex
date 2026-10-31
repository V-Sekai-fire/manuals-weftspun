# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2367-the-station-port-renders-in-godot-from-baked-meshes.exs
defmodule Rfd2367 do
  use Taskweft.DSL

  @name "rfd_2367"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2367": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2367": 2}}
  }

  @todo_list [
    ["prepare", "2367"],
    ["land", "2367"]
  ]
end
