# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2238-g1-sim-to-real-environment.exs
defmodule Rfd2238 do
  use Taskweft.DSL

  @name "rfd_2238"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2238": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2238": 0}}
  }

  @todo_list [
    ["prepare", "2238"],
    ["land", "2238"]
  ]
end
