# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2427-frontier-learning-picks-the-garment-handover-timing-runs.exs
defmodule Rfd2427 do
  use Taskweft.DSL

  @name "rfd_2427"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2427": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2427": 1}}
  }

  @todo_list [
    ["prepare", "2427"],
    ["land", "2427"]
  ]
end
