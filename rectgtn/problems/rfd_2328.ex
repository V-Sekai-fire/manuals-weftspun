# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2328-finger-skin-weights-from-a-fitted-anny-hand.exs
defmodule Rfd2328 do
  use Taskweft.DSL

  @name "rfd_2328"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2328": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2328": 1}}
  }

  @todo_list [
    ["prepare", "2328"],
    ["land", "2328"]
  ]
end
