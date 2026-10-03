# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2134-cluster-tls-is-decided-before-data.exs
defmodule Rfd2134 do
  use Taskweft.DSL

  @name "rfd_2134"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2134": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2134": 0}}
  }

  @todo_list [
    ["prepare", "2134"],
    ["land", "2134"]
  ]
end
