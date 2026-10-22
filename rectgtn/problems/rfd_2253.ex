# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2253-a-character-creator-on-anny.exs
defmodule Rfd2253 do
  use Taskweft.DSL

  @name "rfd_2253"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2253": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2253": 0}}
  }

  @todo_list [
    ["prepare", "2253"],
    ["land", "2253"]
  ]
end
