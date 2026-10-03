# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2279-one-deform-surface-over-curvenets.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2279 do
  use Taskweft.DSL

  @name "rfd_2279"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2279": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2279": 0}}
  }

  @todo_list [
    ["prepare", "2279"],
    ["land", "2279"]
  ]
end
