# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2425-both-avatars-are-free-apache-2-0-models.exs
defmodule Rfd2425 do
  use Taskweft.DSL

  @name "rfd_2425"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2425": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2425": 1}}
  }

  @todo_list [
    ["prepare", "2425"],
    ["land", "2425"]
  ]
end
