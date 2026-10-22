# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1165-finetuning-exhausts-the-desk-card.exs
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
