# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2375-the-game-ships-to-the-headset-as-a-windows-build.exs
defmodule Rfd2375 do
  use Taskweft.DSL

  @name "rfd_2375"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2375": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2375": 2}}
  }

  @todo_list [
    ["prepare", "2375"],
    ["land", "2375"]
  ]
end
