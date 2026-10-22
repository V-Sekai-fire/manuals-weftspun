# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1018-m3-documentation-removal.exs
defmodule Rfd1018 do
  use Taskweft.DSL

  @name "rfd_1018"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1018": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1018": 0}}
  }

  @todo_list [
    ["prepare", "1018"],
    ["land", "1018"]
  ]
end
