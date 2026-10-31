# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2364-the-whole-stack-deploys-offline-on-one-laptop.exs
defmodule Rfd2364 do
  use Taskweft.DSL

  @name "rfd_2364"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2364": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2364": 2}}
  }

  @todo_list [
    ["prepare", "2364"],
    ["land", "2364"]
  ]
end
