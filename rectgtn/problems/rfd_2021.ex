# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2021-require-pr-and-merge-queue-on-main.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2021 do
  use Taskweft.DSL

  @name "rfd_2021"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2021": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2021": 0}}
  }

  @todo_list [
    ["prepare", "2021"],
    ["land", "2021"]
  ]
end
