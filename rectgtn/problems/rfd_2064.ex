# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2064-kebab-case-repos-snake-case-local-checkouts.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2064 do
  use Taskweft.DSL

  @name "rfd_2064"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2064": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2064": 0}}
  }

  @todo_list [
    ["prepare", "2064"],
    ["land", "2064"]
  ]
end
