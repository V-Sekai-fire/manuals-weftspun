# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1121-layers-from-geometry-and-the-missing-categories.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1121 do
  use Taskweft.DSL

  @name "rfd_1121"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1121": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1121": 0}}
  }

  @todo_list [
    ["prepare", "1121"],
    ["land", "1121"]
  ]
end
