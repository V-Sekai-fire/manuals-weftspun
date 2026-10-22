# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2121-amend-rfd-2111-against-the-tree.exs
defmodule Rfd2121 do
  use Taskweft.DSL

  @name "rfd_2121"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2121": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2121": 0}}
  }

  @todo_list [
    ["prepare", "2121"],
    ["land", "2121"]
  ]
end
