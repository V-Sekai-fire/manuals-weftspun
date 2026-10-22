# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2251-image-to-godot-character-as-an-fbd.exs
defmodule Rfd2251 do
  use Taskweft.DSL

  @name "rfd_2251"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2251": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2251": 0}}
  }

  @todo_list [
    ["prepare", "2251"],
    ["land", "2251"]
  ]
end
