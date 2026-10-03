# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2300-sinew-sim-rung-ladder.exs
defmodule Rfd2300 do
  use Taskweft.DSL

  @name "rfd_2300"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2300": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2300": 1}}
  }

  @todo_list [
    ["prepare", "2300"],
    ["land", "2300"]
  ]
end
