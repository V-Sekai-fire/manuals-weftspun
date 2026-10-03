# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2188-one-ggml-across-workspace.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2188 do
  use Taskweft.DSL

  @name "rfd_2188"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2188": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2188": 0}}
  }

  @todo_list [
    ["prepare", "2188"],
    ["land", "2188"]
  ]
end
