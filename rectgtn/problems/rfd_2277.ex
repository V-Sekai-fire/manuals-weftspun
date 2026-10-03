# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2277-curvenet-cage-refit-and-unified-expressions-in-modular-avatar.exs
defmodule Rfd2277 do
  use Taskweft.DSL

  @name "rfd_2277"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2277": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2277": 2}}
  }

  @todo_list [
    ["prepare", "2277"],
    ["land", "2277"]
  ]
end
