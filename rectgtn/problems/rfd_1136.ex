# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1136-camera-vocabulary-and-the-96-pose-grid.exs
defmodule Rfd1136 do
  use Taskweft.DSL

  @name "rfd_1136"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1136": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1136": 0}}
  }

  @todo_list [
    ["prepare", "1136"],
    ["land", "1136"]
  ]
end
