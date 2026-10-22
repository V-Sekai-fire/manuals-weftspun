# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2264-mesh-repair-by-voxel-remesh.exs
defmodule Rfd2264 do
  use Taskweft.DSL

  @name "rfd_2264"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2264": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2264": 1}}
  }

  @todo_list [
    ["prepare", "2264"],
    ["land", "2264"]
  ]
end
