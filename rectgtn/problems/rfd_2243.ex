# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2243-assembly-one-cycle-blockers.exs
defmodule Rfd2243 do
  use Taskweft.DSL

  @name "rfd_2243"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2243": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2243": 0}}
  }

  @todo_list [
    ["prepare", "2243"],
    ["land", "2243"]
  ]
end
