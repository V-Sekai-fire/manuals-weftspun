# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2322-a-mac-dashboard-and-theatre-mode.exs
defmodule Rfd2322 do
  use Taskweft.DSL

  @name "rfd_2322"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2322": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2322": 1}}
  }

  @todo_list [
    ["prepare", "2322"],
    ["land", "2322"]
  ]
end
