# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2277-curvenet-cage-refit-and-unified-expressions-in-modular-avatar.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
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
