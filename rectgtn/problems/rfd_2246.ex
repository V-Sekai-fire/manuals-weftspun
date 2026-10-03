# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2246-editscore-omnigen-bootstrap-for-unmapped-parts.exs
defmodule Rfd2246 do
  use Taskweft.DSL

  @name "rfd_2246"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2246": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2246": 0}}
  }

  @todo_list [
    ["prepare", "2246"],
    ["land", "2246"]
  ]
end
