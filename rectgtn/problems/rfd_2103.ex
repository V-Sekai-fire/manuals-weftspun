# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2103-uro-on-ecto-foundationdb.exs
defmodule Rfd2103 do
  use Taskweft.DSL

  @name "rfd_2103"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2103": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2103": 0}}
  }

  @todo_list [
    ["prepare", "2103"],
    ["land", "2103"]
  ]
end
