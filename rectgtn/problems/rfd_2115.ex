# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2115-a-planner-domain-document-is-a-cheap-layer-surface.exs
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
