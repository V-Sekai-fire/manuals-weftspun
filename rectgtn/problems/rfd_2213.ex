# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2213-vrm-via-godot-sandbox-elf.exs
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
