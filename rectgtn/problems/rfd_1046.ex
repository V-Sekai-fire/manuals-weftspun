# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1046-skintokens-auto-rig.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1046 do
  use Taskweft.DSL

  @name "rfd_1046"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1046": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1046": 0}}
  }

  @todo_list [
    ["prepare", "1046"],
    ["land", "1046"]
  ]
end
