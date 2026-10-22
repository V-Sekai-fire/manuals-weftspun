# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2275-unified-expressions-by-fitting-a-parametric-head.exs
defmodule Rfd2275 do
  use Taskweft.DSL

  @name "rfd_2275"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2275": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2275": 0}}
  }

  @todo_list [
    ["prepare", "2275"],
    ["land", "2275"]
  ]
end
