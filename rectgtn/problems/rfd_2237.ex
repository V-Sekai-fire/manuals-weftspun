# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2237-body-scan-controller.exs
defmodule Rfd2237 do
  use Taskweft.DSL

  @name "rfd_2237"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2237": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2237": 0}}
  }

  @todo_list [
    ["prepare", "2237"],
    ["land", "2237"]
  ]
end
