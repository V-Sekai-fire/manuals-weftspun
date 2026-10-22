# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2185-hierarchical-oid-part-registry.exs
defmodule Rfd2185 do
  use Taskweft.DSL

  @name "rfd_2185"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2185": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2185": 0}}
  }

  @todo_list [
    ["prepare", "2185"],
    ["land", "2185"]
  ]
end
