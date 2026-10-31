# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2366-a-short-runs-forty-seconds-in-four-beats.exs
defmodule Rfd2366 do
  use Taskweft.DSL

  @name "rfd_2366"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2366": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2366": 2}}
  }

  @todo_list [
    ["prepare", "2366"],
    ["land", "2366"]
  ]
end
