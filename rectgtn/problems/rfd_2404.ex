# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2404-the-evidence-step-records-one-session.exs
defmodule Rfd2404 do
  use Taskweft.DSL

  @name "rfd_2404"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2404": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2404": 1}}
  }

  @todo_list [
    ["prepare", "2404"],
    ["land", "2404"]
  ]
end
