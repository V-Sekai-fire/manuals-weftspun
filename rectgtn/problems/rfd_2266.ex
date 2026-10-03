# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2266-simulator-runtime-on-linux.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2266 do
  use Taskweft.DSL

  @name "rfd_2266"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2266": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2266": 1}}
  }

  @todo_list [
    ["prepare", "2266"],
    ["land", "2266"]
  ]
end
