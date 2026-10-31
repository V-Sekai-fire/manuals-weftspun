# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2371-a-residual-is-fixed-down-a-ladder-never-smudged.exs
defmodule Rfd2371 do
  use Taskweft.DSL

  @name "rfd_2371"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2371": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2371": 2}}
  }

  @todo_list [
    ["prepare", "2371"],
    ["land", "2371"]
  ]
end
