# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2115-a-planner-domain-document-is-a-cheap-layer-surface.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2115 do
  use Taskweft.DSL

  @name "rfd_2115"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2115": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2115": 0}}
  }

  @todo_list [
    ["prepare", "2115"],
    ["land", "2115"]
  ]
end
