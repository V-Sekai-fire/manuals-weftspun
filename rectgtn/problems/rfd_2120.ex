# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2120-the-gyre-became-a-settlement-game.exs
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
