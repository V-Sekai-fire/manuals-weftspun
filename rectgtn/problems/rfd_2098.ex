# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2098-rollback-snapshot-budget.exs
defmodule Rfd2098 do
  use Taskweft.DSL

  @name "rfd_2098"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2098": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2098": 0}}
  }

  @todo_list [
    ["prepare", "2098"],
    ["land", "2098"]
  ]
end
