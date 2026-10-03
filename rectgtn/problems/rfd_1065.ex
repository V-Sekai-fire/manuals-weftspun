# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1065-taskweft-domain-schema-in-etnf.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1065 do
  use Taskweft.DSL

  @name "rfd_1065"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1065": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1065": 0}}
  }

  @todo_list [
    ["prepare", "1065"],
    ["land", "1065"]
  ]
end
