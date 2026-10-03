# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2147-bao-is-critical-infrastructure.exs
defmodule Rfd2147 do
  use Taskweft.DSL

  @name "rfd_2147"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2147": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2147": 0}}
  }

  @todo_list [
    ["prepare", "2147"],
    ["land", "2147"]
  ]
end
