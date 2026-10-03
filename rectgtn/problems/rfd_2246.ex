# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2246-editscore-omnigen-bootstrap-for-unmapped-parts.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2246 do
  use Taskweft.DSL

  @name "rfd_2246"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2246": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2246": 0}}
  }

  @todo_list [
    ["prepare", "2246"],
    ["land", "2246"]
  ]
end
