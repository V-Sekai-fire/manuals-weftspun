# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2244-one-deformation-operator.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2244 do
  use Taskweft.DSL

  @name "rfd_2244"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2244": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2244": 0}}
  }

  @todo_list [
    ["prepare", "2244"],
    ["land", "2244"]
  ]
end
