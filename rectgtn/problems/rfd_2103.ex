# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2103-uro-on-ecto-foundationdb.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2103 do
  use Taskweft.DSL

  @name "rfd_2103"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2103": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2103": 0}}
  }

  @todo_list [
    ["prepare", "2103"],
    ["land", "2103"]
  ]
end
