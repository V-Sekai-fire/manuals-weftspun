# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1149-mtoon-shades-against-the-key-light.exs
defmodule Rfd1149 do
  use Taskweft.DSL

  @name "rfd_1149"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1149": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1149": 0}}
  }

  @todo_list [
    ["prepare", "1149"],
    ["land", "1149"]
  ]
end
