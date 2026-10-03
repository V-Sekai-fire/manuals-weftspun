# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1106-weftspun-moat-overview.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1106 do
  use Taskweft.DSL

  @name "rfd_1106"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1106": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1106": 0}}
  }

  @todo_list [
    ["prepare", "1106"],
    ["land", "1106"]
  ]
end
