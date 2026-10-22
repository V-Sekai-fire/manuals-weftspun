# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2191-unrolled-solver-residual-measurement.exs
defmodule Rfd2191 do
  use Taskweft.DSL

  @name "rfd_2191"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2191": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2191": 0}}
  }

  @todo_list [
    ["prepare", "2191"],
    ["land", "2191"]
  ]
end
