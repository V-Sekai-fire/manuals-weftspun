# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2278-voxel-remeshing-for-cages-and-solids.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2278 do
  use Taskweft.DSL

  @name "rfd_2278"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2278": 1}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2278": 1}}
  }

  @todo_list [
    ["prepare", "2278"],
    ["land", "2278"]
  ]
end
