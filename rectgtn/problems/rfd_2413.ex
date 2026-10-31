# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2413-a-desk-works-from-the-placed-tree-and-turns-a-repeated-procedure-into-a-tool.exs
defmodule Rfd2413 do
  use Taskweft.DSL

  @name "rfd_2413"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2413": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2413": 2}}
  }

  @todo_list [
    ["prepare", "2413"],
    ["land", "2413"]
  ]
end
