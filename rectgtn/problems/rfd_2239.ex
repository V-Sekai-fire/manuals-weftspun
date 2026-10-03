# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2239-traits-and-one-binary.exs
defmodule Rfd2239 do
  use Taskweft.DSL

  @name "rfd_2239"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2239": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2239": 0}}
  }

  @todo_list [
    ["prepare", "2239"],
    ["land", "2239"]
  ]
end
