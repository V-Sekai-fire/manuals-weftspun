# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2209-cc-by-nc-blocklist-entry.exs
defmodule Rfd2209 do
  use Taskweft.DSL

  @name "rfd_2209"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2209": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2209": 0}}
  }

  @todo_list [
    ["prepare", "2209"],
    ["land", "2209"]
  ]
end
