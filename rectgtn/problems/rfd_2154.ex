# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2154-openplc4-to-godot-sandbox.exs
defmodule Rfd2154 do
  use Taskweft.DSL

  @name "rfd_2154"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2154": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2154": 0}}
  }

  @todo_list [
    ["prepare", "2154"],
    ["land", "2154"]
  ]
end
