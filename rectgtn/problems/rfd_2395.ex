# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2395-the-draw-step-runs-the-pipeline-and-lassoes-a-target.exs
defmodule Rfd2395 do
  use Taskweft.DSL

  @name "rfd_2395"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2395": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2395": 1}}
  }

  @todo_list [
    ["prepare", "2395"],
    ["land", "2395"]
  ]
end
