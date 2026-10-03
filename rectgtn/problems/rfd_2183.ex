# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2183-retrain-omnigen-for-layer-decomposition.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2183 do
  use Taskweft.DSL

  @name "rfd_2183"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2183": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2183": 0}}
  }

  @todo_list [
    ["prepare", "2183"],
    ["land", "2183"]
  ]
end
