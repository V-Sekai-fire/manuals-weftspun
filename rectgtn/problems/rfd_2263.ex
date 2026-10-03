# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2263-the-skateboards-simulator-gate.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2263 do
  use Taskweft.DSL

  @name "rfd_2263"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2263": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2263": 1}}
  }

  @todo_list [
    ["prepare", "2263"],
    ["land", "2263"]
  ]
end
