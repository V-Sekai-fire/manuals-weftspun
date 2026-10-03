# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2020-pin-engine-to-frozen-godot-4-7.exs
defmodule Rfd2020 do
  use Taskweft.DSL

  @name "rfd_2020"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2020": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2020": 0}}
  }

  @todo_list [
    ["prepare", "2020"],
    ["land", "2020"]
  ]
end
