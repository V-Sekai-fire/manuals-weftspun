# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2175-abandon-rented-compute-rfds.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2175 do
  use Taskweft.DSL

  @name "rfd_2175"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2175": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2175": 0}}
  }

  @todo_list [
    ["prepare", "2175"],
    ["land", "2175"]
  ]
end
