# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/1173-a-multimodal-diffusion-pipeline.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd1173 do
  use Taskweft.DSL

  @name "rfd_1173"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1173": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1173": 0}}
  }

  @todo_list [
    ["prepare", "1173"],
    ["land", "1173"]
  ]
end
