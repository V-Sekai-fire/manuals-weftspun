# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2407-dev-1-and-dev-2-play-on-macos-through-oxrsys.exs
defmodule Rfd2407 do
  use Taskweft.DSL

  @name "rfd_2407"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2407": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2407": 1}}
  }

  @todo_list [
    ["prepare", "2407"],
    ["land", "2407"]
  ]
end
