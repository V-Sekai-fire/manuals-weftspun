# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2415-test-marks-go-only-in-test-scenes.exs
defmodule Rfd2415 do
  use Taskweft.DSL

  @name "rfd_2415"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2415": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2415": 2}}
  }

  @todo_list [
    ["prepare", "2415"],
    ["land", "2415"]
  ]
end
