# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2381-a-windows-host-answers-four-system-calls-as-linux-does.exs
defmodule Rfd2381 do
  use Taskweft.DSL

  @name "rfd_2381"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2381": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2381": 2}}
  }

  @todo_list [
    ["prepare", "2381"],
    ["land", "2381"]
  ]
end
