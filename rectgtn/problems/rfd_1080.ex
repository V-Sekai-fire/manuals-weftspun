# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1080-fly-deploy-cost.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1080 do
  use Taskweft.DSL

  @name "rfd_1080"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1080": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1080": 0}}
  }

  @todo_list [
    ["prepare", "1080"],
    ["land", "1080"]
  ]
end
