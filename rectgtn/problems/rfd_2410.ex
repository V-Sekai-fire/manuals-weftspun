# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2410-rc-two-people-in-one-zone-talking.exs
defmodule Rfd2410 do
  use Taskweft.DSL

  @name "rfd_2410"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2410": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2410": 1}}
  }

  @todo_list [
    ["prepare", "2410"],
    ["land", "2410"]
  ]
end
