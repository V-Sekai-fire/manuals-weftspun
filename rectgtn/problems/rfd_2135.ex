# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2135-checks-run-where-the-credentials-already-are.exs
defmodule Rfd2135 do
  use Taskweft.DSL

  @name "rfd_2135"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2135": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2135": 0}}
  }

  @todo_list [
    ["prepare", "2135"],
    ["land", "2135"]
  ]
end
