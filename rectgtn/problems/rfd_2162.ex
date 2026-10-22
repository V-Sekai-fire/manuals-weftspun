# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2162-maskscore-usdz-skinning-and-15-edit-emit.exs
defmodule Rfd2162 do
  use Taskweft.DSL

  @name "rfd_2162"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2162": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2162": 0}}
  }

  @todo_list [
    ["prepare", "2162"],
    ["land", "2162"]
  ]
end
