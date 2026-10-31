# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2372-heavy-compute-runs-in-a-godot-sandbox-guest.exs
defmodule Rfd2372 do
  use Taskweft.DSL

  @name "rfd_2372"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2372": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2372": 2}}
  }

  @todo_list [
    ["prepare", "2372"],
    ["land", "2372"]
  ]
end
