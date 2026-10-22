# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2189-stick-figure-sanity-check-for-pose-corpus.exs
defmodule Rfd2189 do
  use Taskweft.DSL

  @name "rfd_2189"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2189": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2189": 0}}
  }

  @todo_list [
    ["prepare", "2189"],
    ["land", "2189"]
  ]
end
