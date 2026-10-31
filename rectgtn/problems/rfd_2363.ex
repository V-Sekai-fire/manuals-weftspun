# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2363-a-person-moves-by-world-grab-or-by-controllers.exs
defmodule Rfd2363 do
  use Taskweft.DSL

  @name "rfd_2363"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2363": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2363": 2}}
  }

  @todo_list [
    ["prepare", "2363"],
    ["land", "2363"]
  ]
end
