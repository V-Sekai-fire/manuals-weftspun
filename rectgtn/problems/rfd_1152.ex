# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1152-background-removal-photographic-corpora.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1152 do
  use Taskweft.DSL

  @name "rfd_1152"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1152": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1152": 0}}
  }

  @todo_list [
    ["prepare", "1152"],
    ["land", "1152"]
  ]
end
