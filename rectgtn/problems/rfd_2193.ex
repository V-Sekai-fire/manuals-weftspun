# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2193-editscore-as-constructed-synthetic-reproducibility-bar.exs
defmodule Rfd2193 do
  use Taskweft.DSL

  @name "rfd_2193"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2193": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2193": 0}}
  }

  @todo_list [
    ["prepare", "2193"],
    ["land", "2193"]
  ]
end
