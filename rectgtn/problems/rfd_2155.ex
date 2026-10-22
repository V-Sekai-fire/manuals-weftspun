# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2155-gdscript-fbd-transpiler.exs
defmodule Rfd2155 do
  use Taskweft.DSL

  @name "rfd_2155"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2155": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2155": 0}}
  }

  @todo_list [
    ["prepare", "2155"],
    ["land", "2155"]
  ]
end
