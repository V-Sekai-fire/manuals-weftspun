# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2236-fbd-teacher-in-three-steps.exs
defmodule Rfd2236 do
  use Taskweft.DSL

  @name "rfd_2236"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2236": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2236": 0}}
  }

  @todo_list [
    ["prepare", "2236"],
    ["land", "2236"]
  ]
end
