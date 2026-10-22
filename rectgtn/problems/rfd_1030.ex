# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1030-seethrough-component-models.exs
defmodule Rfd1030 do
  use Taskweft.DSL

  @name "rfd_1030"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1030": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1030": 0}}
  }

  @todo_list [
    ["prepare", "1030"],
    ["land", "1030"]
  ]
end
