# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2168-retract-wholebody-detector-keep-renderer.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2168 do
  use Taskweft.DSL

  @name "rfd_2168"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2168": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2168": 0}}
  }

  @todo_list [
    ["prepare", "2168"],
    ["land", "2168"]
  ]
end
