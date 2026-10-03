# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2113-foundationdb-on-windows-built-from-source.exs
defmodule Rfd2113 do
  use Taskweft.DSL

  @name "rfd_2113"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2113": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2113": 0}}
  }

  @todo_list [
    ["prepare", "2113"],
    ["land", "2113"]
  ]
end
