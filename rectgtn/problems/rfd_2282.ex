# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2282-pose-correctives-as-bones.exs
defmodule Rfd2282 do
  use Taskweft.DSL

  @name "rfd_2282"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2282": 1}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2282": 0}}
  }

  @todo_list [
    ["prepare", "2282"],
    ["land", "2282"]
  ]
end
