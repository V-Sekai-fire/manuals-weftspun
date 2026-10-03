# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2162-maskscore-usdz-skinning-and-15-edit-emit.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2162 do
  use Taskweft.DSL

  @name "rfd_2162"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2162": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2162": 0}}
  }

  @todo_list [
    ["prepare", "2162"],
    ["land", "2162"]
  ]
end
