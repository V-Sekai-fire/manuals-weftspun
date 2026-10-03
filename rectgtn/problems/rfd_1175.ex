# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1175-game.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1175 do
  use Taskweft.DSL

  @name "rfd_1175"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1175": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1175": 0}}
  }

  @todo_list [
    ["prepare", "1175"],
    ["land", "1175"]
  ]
end
