# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2424-a-free-space-sketch-is-fitted-to-the-avatar-from-keypoints.exs
defmodule Rfd2424 do
  use Taskweft.DSL

  @name "rfd_2424"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2424": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2424": 1}}
  }

  @todo_list [
    ["prepare", "2424"],
    ["land", "2424"]
  ]
end
