# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1044-seethrough-layer-decomposition.exs
defmodule Rfd1044 do
  use Taskweft.DSL

  @name "rfd_1044"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1044": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1044": 0}}
  }

  @todo_list [
    ["prepare", "1044"],
    ["land", "1044"]
  ]
end
