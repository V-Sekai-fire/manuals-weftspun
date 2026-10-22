# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2200-rebac-agent-roles.exs
defmodule Rfd2200 do
  use Taskweft.DSL

  @name "rfd_2200"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2200": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2200": 0}}
  }

  @todo_list [
    ["prepare", "2200"],
    ["land", "2200"]
  ]
end
