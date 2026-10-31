# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2423-the-setting-is-a-port-of-the-sakuragaoka-station-plaza.exs
defmodule Rfd2423 do
  use Taskweft.DSL

  @name "rfd_2423"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2423": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2423": 1}}
  }

  @todo_list [
    ["prepare", "2423"],
    ["land", "2423"]
  ]
end
