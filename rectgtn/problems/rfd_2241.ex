# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2241-audio-pose-from-speaking-faces.exs
defmodule Rfd2241 do
  use Taskweft.DSL

  @name "rfd_2241"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2241": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2241": 0}}
  }

  @todo_list [
    ["prepare", "2241"],
    ["land", "2241"]
  ]
end
