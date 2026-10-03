# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2204-rectgtn-fleet-coordination.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2204 do
  use Taskweft.DSL

  @name "rfd_2204"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2204": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2204": 0}}
  }

  @todo_list [
    ["prepare", "2204"],
    ["land", "2204"]
  ]
end
