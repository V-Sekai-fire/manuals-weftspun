# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2028-hexagonal-core-ports-adapters.exs
defmodule Rfd2028 do
  use Taskweft.DSL

  @name "rfd_2028"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2028": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2028": 0}}
  }

  @todo_list [
    ["prepare", "2028"],
    ["land", "2028"]
  ]
end
