# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1040-pixal3d-image-to-textured-mesh.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1040 do
  use Taskweft.DSL

  @name "rfd_1040"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1040": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1040": 0}}
  }

  @todo_list [
    ["prepare", "1040"],
    ["land", "1040"]
  ]
end
