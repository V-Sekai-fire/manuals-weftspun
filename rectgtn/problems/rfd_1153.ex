# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1153-judging-matte-quality.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1153 do
  use Taskweft.DSL

  @name "rfd_1153"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1153": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1153": 0}}
  }

  @todo_list [
    ["prepare", "1153"],
    ["land", "1153"]
  ]
end
