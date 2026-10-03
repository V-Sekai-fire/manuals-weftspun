# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2101-zstd-delta-on-the-wire.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2101 do
  use Taskweft.DSL

  @name "rfd_2101"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2101": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2101": 0}}
  }

  @todo_list [
    ["prepare", "2101"],
    ["land", "2101"]
  ]
end
