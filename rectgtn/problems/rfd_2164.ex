# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2164-maskscore-speech-stub-panel-and-cloning.exs
defmodule Rfd2164 do
  use Taskweft.DSL

  @name "rfd_2164"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2164": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2164": 0}}
  }

  @todo_list [
    ["prepare", "2164"],
    ["land", "2164"]
  ]
end
