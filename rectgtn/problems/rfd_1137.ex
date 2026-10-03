# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1137-encoding-a-frame-set.exs
defmodule Rfd1137 do
  use Taskweft.DSL

  @name "rfd_1137"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1137": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1137": 0}}
  }

  @todo_list [
    ["prepare", "1137"],
    ["land", "1137"]
  ]
end
