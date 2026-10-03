# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2209-cc-by-nc-blocklist-entry.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
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
