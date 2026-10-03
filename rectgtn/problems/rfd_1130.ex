# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1130-ugen300-throughput.exs
defmodule Rfd1130 do
  use Taskweft.DSL

  @name "rfd_1130"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1130": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1130": 0}}
  }

  @todo_list [
    ["prepare", "1130"],
    ["land", "1130"]
  ]
end
