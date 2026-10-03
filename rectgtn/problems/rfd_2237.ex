# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2237-body-scan-controller.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2237 do
  use Taskweft.DSL

  @name "rfd_2237"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2237": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2237": 0}}
  }

  @todo_list [
    ["prepare", "2237"],
    ["land", "2237"]
  ]
end
