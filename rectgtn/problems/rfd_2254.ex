# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2254-order-independent-transparency-for-cad.exs
defmodule Rfd2254 do
  use Taskweft.DSL

  @name "rfd_2254"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2254": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2254": 0}}
  }

  @todo_list [
    ["prepare", "2254"],
    ["land", "2254"]
  ]
end
