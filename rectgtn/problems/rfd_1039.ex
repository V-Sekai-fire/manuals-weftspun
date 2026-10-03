# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1039-trellis2-image-mesh-painting.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1039 do
  use Taskweft.DSL

  @name "rfd_1039"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1039": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1039": 0}}
  }

  @todo_list [
    ["prepare", "1039"],
    ["land", "1039"]
  ]
end
