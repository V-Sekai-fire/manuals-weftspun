# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2426-the-garment-handover-is-timed-per-leg.exs
defmodule Rfd2426 do
  use Taskweft.DSL

  @name "rfd_2426"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2426": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2426": 1}}
  }

  @todo_list [
    ["prepare", "2426"],
    ["land", "2426"]
  ]
end
