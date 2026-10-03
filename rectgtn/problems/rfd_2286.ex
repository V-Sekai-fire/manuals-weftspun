# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2286-a-phone-face-bridge-to-social-vr.exs
defmodule Rfd2286 do
  use Taskweft.DSL

  @name "rfd_2286"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2286": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2286": 0}}
  }

  @todo_list [
    ["prepare", "2286"],
    ["land", "2286"]
  ]
end
