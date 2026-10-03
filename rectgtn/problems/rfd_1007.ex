# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1007-motion-validation-kimodo.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1007 do
  use Taskweft.DSL

  @name "rfd_1007"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1007": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1007": 0}}
  }

  @todo_list [
    ["prepare", "1007"],
    ["land", "1007"]
  ]
end
