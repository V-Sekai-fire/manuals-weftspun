# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1165-finetuning-exhausts-the-desk-card.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1165 do
  use Taskweft.DSL

  @name "rfd_1165"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1165": 1}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1165": 0}}
  }

  @todo_list [
    ["prepare", "1165"],
    ["land", "1165"]
  ]
end
