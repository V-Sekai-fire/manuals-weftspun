# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2207-nord-palette-for-demos.exs
defmodule Rfd2207 do
  use Taskweft.DSL

  @name "rfd_2207"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2207": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2207": 0}}
  }

  @todo_list [
    ["prepare", "2207"],
    ["land", "2207"]
  ]
end
