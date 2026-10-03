# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2032-core-codegen-lean-slang.exs
defmodule Rfd2032 do
  use Taskweft.DSL

  @name "rfd_2032"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2032": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2032": 0}}
  }

  @todo_list [
    ["prepare", "2032"],
    ["land", "2032"]
  ]
end
