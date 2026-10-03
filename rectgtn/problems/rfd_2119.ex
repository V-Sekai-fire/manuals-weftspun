# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2119-salvage-you-can-hold.exs
defmodule Rfd2119 do
  use Taskweft.DSL

  @name "rfd_2119"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2119": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2119": 0}}
  }

  @todo_list [
    ["prepare", "2119"],
    ["land", "2119"]
  ]
end
