# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1063-ste-enforcement-moves-to-the-plugin.exs
defmodule Rfd1063 do
  use Taskweft.DSL

  @name "rfd_1063"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1063": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1063": 0}}
  }

  @todo_list [
    ["prepare", "1063"],
    ["land", "1063"]
  ]
end
