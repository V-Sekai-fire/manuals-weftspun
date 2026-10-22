# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2304-one-lean-4-rectgtn-library-generates-the-planner.exs
defmodule Rfd2304 do
  use Taskweft.DSL

  @name "rfd_2304"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2304": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2304": 2}}
  }

  @todo_list [
    ["prepare", "2304"],
    ["land", "2304"]
  ]
end
