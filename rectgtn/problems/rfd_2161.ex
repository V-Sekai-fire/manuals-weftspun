# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2161-vn-avatar-cleanroom-on-maskscore.exs
defmodule Rfd2161 do
  use Taskweft.DSL

  @name "rfd_2161"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2161": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2161": 0}}
  }

  @todo_list [
    ["prepare", "2161"],
    ["land", "2161"]
  ]
end
