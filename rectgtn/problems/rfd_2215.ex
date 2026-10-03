# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2215-one-binary-two-heads.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2215 do
  use Taskweft.DSL

  @name "rfd_2215"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2215": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2215": 0}}
  }

  @todo_list [
    ["prepare", "2215"],
    ["land", "2215"]
  ]
end
