# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2143-fdb-backup-fans-out-to-r2.exs
defmodule Rfd2143 do
  use Taskweft.DSL

  @name "rfd_2143"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2143": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2143": 0}}
  }

  @todo_list [
    ["prepare", "2143"],
    ["land", "2143"]
  ]
end
