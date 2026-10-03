# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1134-notebooks-tested-in-the-browser.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1134 do
  use Taskweft.DSL

  @name "rfd_1134"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1134": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1134": 0}}
  }

  @todo_list [
    ["prepare", "1134"],
    ["land", "1134"]
  ]
end
