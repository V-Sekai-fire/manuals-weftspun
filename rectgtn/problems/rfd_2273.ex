# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2273-accepting-person-masks-depth-before-judge.exs
defmodule Rfd2273 do
  use Taskweft.DSL

  @name "rfd_2273"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2273": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2273": 0}}
  }

  @todo_list [
    ["prepare", "2273"],
    ["land", "2273"]
  ]
end
