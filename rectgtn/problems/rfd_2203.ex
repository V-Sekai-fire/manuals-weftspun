# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2203-anny-soma-first-subset-corpus-shape.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2203 do
  use Taskweft.DSL

  @name "rfd_2203"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2203": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2203": 0}}
  }

  @todo_list [
    ["prepare", "2203"],
    ["land", "2203"]
  ]
end
