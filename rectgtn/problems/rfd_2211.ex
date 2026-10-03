# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2211-base-tree-entities-godot-sandbox.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2211 do
  use Taskweft.DSL

  @name "rfd_2211"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2211": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2211": 0}}
  }

  @todo_list [
    ["prepare", "2211"],
    ["land", "2211"]
  ]
end
