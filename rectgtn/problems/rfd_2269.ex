# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2269-curvenet-parity-gate-is-interval-arithmetic.exs
defmodule Rfd2269 do
  use Taskweft.DSL

  @name "rfd_2269"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2269": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2269": 1}}
  }

  @todo_list [
    ["prepare", "2269"],
    ["land", "2269"]
  ]
end
