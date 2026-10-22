# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1175-game.exs
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
