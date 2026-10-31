# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2370-a-visual-comparison-is-a-labelled-contact-sheet.exs
defmodule Rfd2370 do
  use Taskweft.DSL

  @name "rfd_2370"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2370": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2370": 2}}
  }

  @todo_list [
    ["prepare", "2370"],
    ["land", "2370"]
  ]
end
