# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2145-certificate-lifetimes.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2145 do
  use Taskweft.DSL

  @name "rfd_2145"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2145": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2145": 0}}
  }

  @todo_list [
    ["prepare", "2145"],
    ["land", "2145"]
  ]
end
