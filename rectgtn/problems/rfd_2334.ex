# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2334-decider-examples-from-traces.exs
defmodule Rfd2334 do
  use Taskweft.DSL

  @name "rfd_2334"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2334": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2334": 0}}
  }

  @todo_list [
    ["prepare", "2334"],
    ["land", "2334"]
  ]
end
