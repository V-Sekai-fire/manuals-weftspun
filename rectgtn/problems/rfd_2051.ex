# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2051-headless-openxr-testing-with-monado.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2051 do
  use Taskweft.DSL

  @name "rfd_2051"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2051": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2051": 0}}
  }

  @todo_list [
    ["prepare", "2051"],
    ["land", "2051"]
  ]
end
