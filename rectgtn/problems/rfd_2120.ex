# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2120-the-gyre-became-a-settlement-game.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2120 do
  use Taskweft.DSL

  @name "rfd_2120"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2120": -2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2120": 0}}
  }

  @todo_list []
end
