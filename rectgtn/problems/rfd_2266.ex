# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2266-simulator-runtime-on-linux.exs
defmodule Rfd2266 do
  use Taskweft.DSL

  @name "rfd_2266"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2266": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2266": 0}}
  }

  @todo_list [
    ["prepare", "2266"],
    ["land", "2266"]
  ]
end
