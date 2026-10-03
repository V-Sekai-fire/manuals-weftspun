# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2216-threejs-blocklist.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2216 do
  use Taskweft.DSL

  @name "rfd_2216"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2216": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2216": 0}}
  }

  @todo_list [
    ["prepare", "2216"],
    ["land", "2216"]
  ]
end
