# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2121-amend-rfd-2111-against-the-tree.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2121 do
  use Taskweft.DSL

  @name "rfd_2121"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2121": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2121": 0}}
  }

  @todo_list [
    ["prepare", "2121"],
    ["land", "2121"]
  ]
end
