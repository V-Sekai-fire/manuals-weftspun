# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2108-local-cabi-guests-and-in-tick-fanout.exs
defmodule Rfd2108 do
  use Taskweft.DSL

  @name "rfd_2108"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2108": -2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2108": 0}}
  }

  @todo_list []
end
