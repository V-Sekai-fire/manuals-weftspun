# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1150-shade-colour-solved-per-tone.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1150 do
  use Taskweft.DSL

  @name "rfd_1150"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1150": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1150": 0}}
  }

  @todo_list [
    ["prepare", "1150"],
    ["land", "1150"]
  ]
end
