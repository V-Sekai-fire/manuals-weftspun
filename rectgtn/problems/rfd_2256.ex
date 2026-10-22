# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2256-webtransport-inside-a-sandbox-guest.exs
defmodule Rfd2256 do
  use Taskweft.DSL

  @name "rfd_2256"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2256": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2256": 0}}
  }

  @todo_list [
    ["prepare", "2256"],
    ["land", "2256"]
  ]
end
