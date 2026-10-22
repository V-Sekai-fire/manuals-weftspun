# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2025-tenseless-continuous-present-voice.exs
defmodule Rfd2025 do
  use Taskweft.DSL

  @name "rfd_2025"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2025": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2025": 0}}
  }

  @todo_list [
    ["prepare", "2025"],
    ["land", "2025"]
  ]
end
