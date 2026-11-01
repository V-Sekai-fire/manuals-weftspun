# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2435-a-garment-is-repaired-as-a-distance-field-surface.exs
defmodule Rfd2435 do
  use Taskweft.DSL

  @name "rfd_2435"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2435": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2435": 1}}
  }

  @todo_list [
    ["prepare", "2435"],
    ["land", "2435"]
  ]
end
