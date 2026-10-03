# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2024-windows-background-services-nssm.exs
defmodule Rfd2024 do
  use Taskweft.DSL

  @name "rfd_2024"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2024": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2024": 0}}
  }

  @todo_list [
    ["prepare", "2024"],
    ["land", "2024"]
  ]
end
