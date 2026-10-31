# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2369-the-standalone-headset-draws-at-most-700k-triangles.exs
defmodule Rfd2369 do
  use Taskweft.DSL

  @name "rfd_2369"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2369": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2369": 2}}
  }

  @todo_list [
    ["prepare", "2369"],
    ["land", "2369"]
  ]
end
