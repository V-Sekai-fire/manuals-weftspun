# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1106-weftspun-moat-overview.exs
defmodule Rfd1106 do
  use Taskweft.DSL

  @name "rfd_1106"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1106": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1106": 0}}
  }

  @todo_list [
    ["prepare", "1106"],
    ["land", "1106"]
  ]
end
