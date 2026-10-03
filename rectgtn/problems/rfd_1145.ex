# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1145-stylized-to-omnigen2.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1145 do
  use Taskweft.DSL

  @name "rfd_1145"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1145": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1145": 0}}
  }

  @todo_list [
    ["prepare", "1145"],
    ["land", "1145"]
  ]
end
