# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2140-openbao-on-foundationdb.exs
defmodule Rfd2140 do
  use Taskweft.DSL

  @name "rfd_2140"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2140": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2140": 0}}
  }

  @todo_list [
    ["prepare", "2140"],
    ["land", "2140"]
  ]
end
