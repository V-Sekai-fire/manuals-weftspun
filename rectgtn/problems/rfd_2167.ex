# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2167-maskscore-voice-reward-distillation.exs
defmodule Rfd2167 do
  use Taskweft.DSL

  @name "rfd_2167"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2167": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2167": 0}}
  }

  @todo_list [
    ["prepare", "2167"],
    ["land", "2167"]
  ]
end
