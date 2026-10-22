# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2058-webtransport-persistent-framed-stream.exs
defmodule Rfd2058 do
  use Taskweft.DSL

  @name "rfd_2058"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2058": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2058": 0}}
  }

  @todo_list [
    ["prepare", "2058"],
    ["land", "2058"]
  ]
end
