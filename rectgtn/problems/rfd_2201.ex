# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2201-coordinate-agents-ceremony.exs
defmodule Rfd2201 do
  use Taskweft.DSL

  @name "rfd_2201"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2201": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2201": 0}}
  }

  @todo_list [
    ["prepare", "2201"],
    ["land", "2201"]
  ]
end
