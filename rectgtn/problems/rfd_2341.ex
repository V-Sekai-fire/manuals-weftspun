# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2341-dev-next.exs
defmodule Rfd2341 do
  use Taskweft.DSL

  @name "rfd_2341"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2341": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2341": 0}}
  }

  @todo_list [
    ["prepare", "2341"],
    ["land", "2341"]
  ]
end
