# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2401-the-talk-step-carries-voice-as-datagrams.exs
defmodule Rfd2401 do
  use Taskweft.DSL

  @name "rfd_2401"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2401": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2401": 1}}
  }

  @todo_list [
    ["prepare", "2401"],
    ["land", "2401"]
  ]
end
