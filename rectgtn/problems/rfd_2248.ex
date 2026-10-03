# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2248-the-avatar-body-is-a-closed-solid.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2248 do
  use Taskweft.DSL

  @name "rfd_2248"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2248": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2248": 1}}
  }

  @todo_list [
    ["prepare", "2248"],
    ["land", "2248"]
  ]
end
