# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1138-where-range-of-motion-comes-from.exs
defmodule Rfd1138 do
  use Taskweft.DSL

  @name "rfd_1138"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1138": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1138": 0}}
  }

  @todo_list [
    ["prepare", "1138"],
    ["land", "1138"]
  ]
end
