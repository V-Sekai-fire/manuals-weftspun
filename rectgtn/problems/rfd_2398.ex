# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2398-the-zone-step-ports-the-fabric-zone-into-a-guest.exs
defmodule Rfd2398 do
  use Taskweft.DSL

  @name "rfd_2398"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2398": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2398": 1}}
  }

  @todo_list [
    ["prepare", "2398"],
    ["land", "2398"]
  ]
end
