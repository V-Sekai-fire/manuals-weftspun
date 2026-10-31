# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2418-our-line-of-an-upstream-branch-is-dev-branch-on-the-fork.exs
defmodule Rfd2418 do
  use Taskweft.DSL

  @name "rfd_2418"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2418": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2418": 2}}
  }

  @todo_list [
    ["prepare", "2418"],
    ["land", "2418"]
  ]
end
