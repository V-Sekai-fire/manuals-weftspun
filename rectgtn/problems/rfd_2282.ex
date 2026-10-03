# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2282-pose-correctives-as-bones.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2282 do
  use Taskweft.DSL

  @name "rfd_2282"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2282": 1}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2282": 1}}
  }

  @todo_list [
    ["prepare", "2282"],
    ["land", "2282"]
  ]
end
