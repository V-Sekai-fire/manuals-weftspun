# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2181-drop-allosaurus-rus.exs
defmodule Rfd2181 do
  use Taskweft.DSL

  @name "rfd_2181"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2181": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2181": 0}}
  }

  @todo_list [
    ["prepare", "2181"],
    ["land", "2181"]
  ]
end
