# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1055-beam-workers-local-first.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1055 do
  use Taskweft.DSL

  @name "rfd_1055"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1055": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1055": 0}}
  }

  @todo_list [
    ["prepare", "1055"],
    ["land", "1055"]
  ]
end
