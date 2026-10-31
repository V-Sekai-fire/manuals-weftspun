# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2374-everything-in-a-godot-sandbox-runs-binary-translated.exs
defmodule Rfd2374 do
  use Taskweft.DSL

  @name "rfd_2374"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2374": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2374": 2}}
  }

  @todo_list [
    ["prepare", "2374"],
    ["land", "2374"]
  ]
end
