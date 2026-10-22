# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1139-conventions-are-measured.exs
defmodule Rfd1139 do
  use Taskweft.DSL

  @name "rfd_1139"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1139": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1139": 0}}
  }

  @todo_list [
    ["prepare", "1139"],
    ["land", "1139"]
  ]
end
