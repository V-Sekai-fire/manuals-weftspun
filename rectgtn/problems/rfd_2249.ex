# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2249-cloth-by-vertex-block-descent.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2249 do
  use Taskweft.DSL

  @name "rfd_2249"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2249": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2249": 1}}
  }

  @todo_list [
    ["prepare", "2249"],
    ["land", "2249"]
  ]
end
