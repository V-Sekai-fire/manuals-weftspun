# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2279-one-deform-surface-over-curvenets.exs
defmodule Rfd2279 do
  use Taskweft.DSL

  @name "rfd_2279"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2279": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2279": 0}}
  }

  @todo_list [
    ["prepare", "2279"],
    ["land", "2279"]
  ]
end
