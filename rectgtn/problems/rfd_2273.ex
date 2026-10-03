# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2273-accepting-person-masks-depth-before-judge.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2273 do
  use Taskweft.DSL

  @name "rfd_2273"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2273": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2273": 1}}
  }

  @todo_list [
    ["prepare", "2273"],
    ["land", "2273"]
  ]
end
