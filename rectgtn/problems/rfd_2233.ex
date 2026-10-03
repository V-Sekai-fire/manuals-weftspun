# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2233-close-out-gates-red-green-scout.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2233 do
  use Taskweft.DSL

  @name "rfd_2233"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2233": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2233": 0}}
  }

  @todo_list [
    ["prepare", "2233"],
    ["land", "2233"]
  ]
end
