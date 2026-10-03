# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2234-dress-on-pipeline.exs
defmodule Rfd2234 do
  use Taskweft.DSL

  @name "rfd_2234"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2234": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2234": 1}}
  }

  @todo_list [
    ["prepare", "2234"],
    ["land", "2234"]
  ]
end
