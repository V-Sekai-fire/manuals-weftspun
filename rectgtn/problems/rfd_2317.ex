# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2317-a-browser-joins-a-webtransport-server-with-a-bao-ticket.exs
defmodule Rfd2317 do
  use Taskweft.DSL

  @name "rfd_2317"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2317": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2317": 2}}
  }

  @todo_list [
    ["prepare", "2317"],
    ["land", "2317"]
  ]
end
