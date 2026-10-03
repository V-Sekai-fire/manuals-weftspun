# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2189-stick-figure-sanity-check-for-pose-corpus.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2189 do
  use Taskweft.DSL

  @name "rfd_2189"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2189": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2189": 0}}
  }

  @todo_list [
    ["prepare", "2189"],
    ["land", "2189"]
  ]
end
