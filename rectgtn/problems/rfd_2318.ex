# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2318-the-avatar-space-is-built-smallest-joy-first.exs
defmodule Rfd2318 do
  use Taskweft.DSL

  @name "rfd_2318"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2318": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2318": 2}}
  }

  @todo_list [
    ["prepare", "2318"],
    ["land", "2318"]
  ]
end
