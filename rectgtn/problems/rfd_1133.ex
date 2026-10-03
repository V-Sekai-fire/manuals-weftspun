# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1133-models-excluded-from-conversion.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1133 do
  use Taskweft.DSL

  @name "rfd_1133"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1133": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1133": 0}}
  }

  @todo_list [
    ["prepare", "1133"],
    ["land", "1133"]
  ]
end
