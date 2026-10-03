# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2288-guest-capabilities-as-macaroons.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2288 do
  use Taskweft.DSL

  @name "rfd_2288"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2288": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2288": 1}}
  }

  @todo_list [
    ["prepare", "2288"],
    ["land", "2288"]
  ]
end
