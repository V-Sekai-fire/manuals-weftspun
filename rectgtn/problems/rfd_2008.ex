# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2008-webtransport-over-quic-for-game-traffic.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2008 do
  use Taskweft.DSL

  @name "rfd_2008"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2008": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2008": 0}}
  }

  @todo_list [
    ["prepare", "2008"],
    ["land", "2008"]
  ]
end
