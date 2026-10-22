# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2205-taskweft-in-bao.exs
defmodule Rfd2205 do
  use Taskweft.DSL

  @name "rfd_2205"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2205": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2205": 0}}
  }

  @todo_list [
    ["prepare", "2205"],
    ["land", "2205"]
  ]
end
