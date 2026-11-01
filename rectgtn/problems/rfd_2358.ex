# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2358-a-party-is-one-player-and-three-seats.exs
defmodule Rfd2358 do
  use Taskweft.DSL

  @name "rfd_2358"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2358": -2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2358": 0}}
  }

  @todo_list []
end
