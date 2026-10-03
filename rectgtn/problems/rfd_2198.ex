# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2198-lladao-speed-work-for-dressing-overlay.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2198 do
  use Taskweft.DSL

  @name "rfd_2198"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2198": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2198": 0}}
  }

  @todo_list [
    ["prepare", "2198"],
    ["land", "2198"]
  ]
end
