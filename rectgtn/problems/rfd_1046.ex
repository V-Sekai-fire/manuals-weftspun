# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1046-skintokens-auto-rig.exs
defmodule Rfd1046 do
  use Taskweft.DSL

  @name "rfd_1046"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1046": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1046": 0}}
  }

  @todo_list [
    ["prepare", "1046"],
    ["land", "1046"]
  ]
end
