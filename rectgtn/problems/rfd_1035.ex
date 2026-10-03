# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1035-legacy-model-identifiers.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1035 do
  use Taskweft.DSL

  @name "rfd_1035"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1035": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1035": 0}}
  }

  @todo_list [
    ["prepare", "1035"],
    ["land", "1035"]
  ]
end
