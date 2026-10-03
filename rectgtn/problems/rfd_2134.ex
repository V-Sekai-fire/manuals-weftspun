# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2134-cluster-tls-is-decided-before-data.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2134 do
  use Taskweft.DSL

  @name "rfd_2134"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2134": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2134": 0}}
  }

  @todo_list [
    ["prepare", "2134"],
    ["land", "2134"]
  ]
end
