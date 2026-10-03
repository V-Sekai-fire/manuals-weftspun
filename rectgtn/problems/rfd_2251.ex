# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2251-image-to-godot-character-as-an-fbd.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
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
