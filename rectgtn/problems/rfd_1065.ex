# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1065-taskweft-domain-schema-in-etnf.exs
defmodule Rfd1065 do
  use Taskweft.DSL

  @name "rfd_1065"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1065": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1065": 0}}
  }

  @todo_list [
    ["prepare", "1065"],
    ["land", "1065"]
  ]
end
