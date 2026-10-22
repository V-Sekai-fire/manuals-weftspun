# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2233-close-out-gates-red-green-scout.exs
defmodule Rfd2233 do
  use Taskweft.DSL

  @name "rfd_2233"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2233": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2233": 0}}
  }

  @todo_list [
    ["prepare", "2233"],
    ["land", "2233"]
  ]
end
