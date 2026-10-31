# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2430-the-gacha-critical-path-is-ten-rungs-from-a-prompt-to-a-public-roll.exs
defmodule Rfd2430 do
  use Taskweft.DSL

  @name "rfd_2430"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2430": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2430": 2}}
  }

  @todo_list [
    ["prepare", "2430"],
    ["land", "2430"]
  ]
end
