# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1041-p3sam-mesh-segmentation.exs
defmodule Rfd1041 do
  use Taskweft.DSL

  @name "rfd_1041"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1041": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1041": 0}}
  }

  @todo_list [
    ["prepare", "1041"],
    ["land", "1041"]
  ]
end
