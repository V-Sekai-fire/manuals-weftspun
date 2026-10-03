# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2097-pubsub-belongs-in-userspace.exs
defmodule Rfd2097 do
  use Taskweft.DSL

  @name "rfd_2097"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2097": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2097": 0}}
  }

  @todo_list [
    ["prepare", "2097"],
    ["land", "2097"]
  ]
end
