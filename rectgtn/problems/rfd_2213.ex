# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2213-vrm-via-godot-sandbox-elf.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2213 do
  use Taskweft.DSL

  @name "rfd_2213"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2213": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2213": 0}}
  }

  @todo_list [
    ["prepare", "2213"],
    ["land", "2213"]
  ]
end
