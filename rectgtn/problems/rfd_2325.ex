# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2325-second-hand-garments-for-the-avatar.exs
defmodule Rfd2325 do
  use Taskweft.DSL

  @name "rfd_2325"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2325": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2325": 1}}
  }

  @todo_list [
    ["prepare", "2325"],
    ["land", "2325"]
  ]
end
