# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1125-two-prose-gates.exs
defmodule Rfd1125 do
  use Taskweft.DSL

  @name "rfd_1125"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1125": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1125": 0}}
  }

  @todo_list [
    ["prepare", "1125"],
    ["land", "1125"]
  ]
end
