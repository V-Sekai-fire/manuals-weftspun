# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2436-presence-is-an-independent-native-slice.exs
defmodule Rfd2436 do
  use Taskweft.DSL

  @name "rfd_2436"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2436": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2436": 1}}
  }

  @todo_list [
    ["prepare", "2436"],
    ["land", "2436"]
  ]
end
