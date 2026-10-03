# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1063-ste-enforcement-moves-to-the-plugin.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1063 do
  use Taskweft.DSL

  @name "rfd_1063"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1063": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1063": 0}}
  }

  @todo_list [
    ["prepare", "1063"],
    ["land", "1063"]
  ]
end
