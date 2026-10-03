# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2175-abandon-rented-compute-rfds.exs
defmodule Rfd2175 do
  use Taskweft.DSL

  @name "rfd_2175"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2175": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2175": 0}}
  }

  @todo_list [
    ["prepare", "2175"],
    ["land", "2175"]
  ]
end
