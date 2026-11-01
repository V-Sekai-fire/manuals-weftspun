# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2337-a-garment-fit-at-mesh-on-the-gpu-l-bfgs-b.exs
defmodule Rfd2337 do
  use Taskweft.DSL

  @name "rfd_2337"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2337": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2337": 0}}
  }

  @todo_list [
    ["prepare", "2337"],
    ["land", "2337"]
  ]
end
