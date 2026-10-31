# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2411-released-the-rung-is-live-and-reproducible-from-a-bare-machine.exs
defmodule Rfd2411 do
  use Taskweft.DSL

  @name "rfd_2411"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2411": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2411": 1}}
  }

  @todo_list [
    ["prepare", "2411"],
    ["land", "2411"]
  ]
end
