# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2179-drop-whisper-models.exs
defmodule Rfd2179 do
  use Taskweft.DSL

  @name "rfd_2179"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2179": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2179": 0}}
  }

  @todo_list [
    ["prepare", "2179"],
    ["land", "2179"]
  ]
end
