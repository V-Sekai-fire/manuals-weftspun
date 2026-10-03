# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2137-rfd-reports-share-one-sheet.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2137 do
  use Taskweft.DSL

  @name "rfd_2137"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2137": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2137": 0}}
  }

  @todo_list [
    ["prepare", "2137"],
    ["land", "2137"]
  ]
end
