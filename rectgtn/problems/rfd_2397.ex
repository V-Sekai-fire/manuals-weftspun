# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2397-the-transport-step-puts-a-certificate-authority-and-capabilities-in-guests.exs
defmodule Rfd2397 do
  use Taskweft.DSL

  @name "rfd_2397"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2397": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2397": 1}}
  }

  @todo_list [
    ["prepare", "2397"],
    ["land", "2397"]
  ]
end
