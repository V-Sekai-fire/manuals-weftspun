# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1142-the-mac-against-the-ugen300.exs
defmodule Rfd1142 do
  use Taskweft.DSL

  @name "rfd_1142"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1142": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1142": 0}}
  }

  @todo_list [
    ["prepare", "1142"],
    ["land", "1142"]
  ]
end
