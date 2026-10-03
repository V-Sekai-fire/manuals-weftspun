# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1150-shade-colour-solved-per-tone.exs
defmodule Rfd1150 do
  use Taskweft.DSL

  @name "rfd_1150"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1150": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1150": 0}}
  }

  @todo_list [
    ["prepare", "1150"],
    ["land", "1150"]
  ]
end
