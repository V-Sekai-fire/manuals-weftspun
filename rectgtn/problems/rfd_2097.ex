# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2097-pubsub-belongs-in-userspace.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
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
