# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1048-voxhammer-image-mesh-editing.exs
defmodule Rfd1048 do
  use Taskweft.DSL

  @name "rfd_1048"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1048": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1048": 0}}
  }

  @todo_list [
    ["prepare", "1048"],
    ["land", "1048"]
  ]
end
