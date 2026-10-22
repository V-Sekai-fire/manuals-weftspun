# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2012-amend-pr-before-it-enters-the-queue.exs
defmodule Rfd2012 do
  use Taskweft.DSL

  @name "rfd_2012"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2012": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2012": 0}}
  }

  @todo_list [
    ["prepare", "2012"],
    ["land", "2012"]
  ]
end
