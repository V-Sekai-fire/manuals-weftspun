# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2338-a-skin-fit-to-four-influences-on-the-gpu-l-bfgs-b.exs
defmodule Rfd2338 do
  use Taskweft.DSL

  @name "rfd_2338"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2338": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2338": 2}}
  }

  @todo_list [
    ["prepare", "2338"],
    ["land", "2338"]
  ]
end
