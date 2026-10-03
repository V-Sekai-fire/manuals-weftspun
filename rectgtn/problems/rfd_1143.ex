# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1143-keypoints-to-anny.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1143 do
  use Taskweft.DSL

  @name "rfd_1143"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1143": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1143": 0}}
  }

  @todo_list [
    ["prepare", "1143"],
    ["land", "1143"]
  ]
end
