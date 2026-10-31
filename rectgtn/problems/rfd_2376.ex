# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2376-nothing-runs-in-the-headset-unless-the-operator-asks.exs
defmodule Rfd2376 do
  use Taskweft.DSL

  @name "rfd_2376"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2376": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2376": 2}}
  }

  @todo_list [
    ["prepare", "2376"],
    ["land", "2376"]
  ]
end
