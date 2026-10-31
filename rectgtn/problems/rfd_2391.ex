# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2391-guests-are-built-at-double-precision.exs
defmodule Rfd2391 do
  use Taskweft.DSL

  @name "rfd_2391"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2391": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2391": 1}}
  }

  @todo_list [
    ["prepare", "2391"],
    ["land", "2391"]
  ]
end
