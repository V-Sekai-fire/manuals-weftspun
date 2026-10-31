# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2406-the-desk-s-stored-github-credentials-are-destroyed.exs
defmodule Rfd2406 do
  use Taskweft.DSL

  @name "rfd_2406"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2406": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2406": 1}}
  }

  @todo_list [
    ["prepare", "2406"],
    ["land", "2406"]
  ]
end
