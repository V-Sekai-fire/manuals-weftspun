# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2250-cloth-fit-as-one-burrito-binary.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2250 do
  use Taskweft.DSL

  @name "rfd_2250"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2250": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2250": 0}}
  }

  @todo_list [
    ["prepare", "2250"],
    ["land", "2250"]
  ]
end
