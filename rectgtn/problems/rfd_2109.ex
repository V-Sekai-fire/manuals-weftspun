# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2109-two-tiers-with-foundationdb-as-the-store.exs
defmodule Rfd2109 do
  use Taskweft.DSL

  @name "rfd_2109"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2109": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2109": 0}}
  }

  @todo_list [
    ["prepare", "2109"],
    ["land", "2109"]
  ]
end
