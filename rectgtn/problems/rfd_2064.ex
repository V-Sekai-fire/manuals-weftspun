# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2064-kebab-case-repos-snake-case-local-checkouts.exs
defmodule Rfd2064 do
  use Taskweft.DSL

  @name "rfd_2064"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2064": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2064": 0}}
  }

  @todo_list [
    ["prepare", "2064"],
    ["land", "2064"]
  ]
end
