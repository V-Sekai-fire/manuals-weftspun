# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1000-conventions.exs
defmodule Rfd1000 do
  use Taskweft.DSL

  @name "rfd_1000"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1000": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1000": 0}}
  }

  @todo_list [
    ["prepare", "1000"],
    ["land", "1000"]
  ]
end
