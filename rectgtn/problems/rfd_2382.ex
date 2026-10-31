# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2382-the-skateboard-has-a-manifest-of-its-own.exs
defmodule Rfd2382 do
  use Taskweft.DSL

  @name "rfd_2382"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2382": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2382": 1}}
  }

  @todo_list [
    ["prepare", "2382"],
    ["land", "2382"]
  ]
end
