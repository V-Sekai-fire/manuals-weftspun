# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2114-prove-the-store-by-breaking-it.exs
defmodule Rfd2114 do
  use Taskweft.DSL

  @name "rfd_2114"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2114": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2114": 0}}
  }

  @todo_list [
    ["prepare", "2114"],
    ["land", "2114"]
  ]
end
