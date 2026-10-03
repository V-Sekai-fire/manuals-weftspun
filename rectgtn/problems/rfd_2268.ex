# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2268-the-recommender-is-a-decision-model.exs
defmodule Rfd2268 do
  use Taskweft.DSL

  @name "rfd_2268"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2268": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2268": 1}}
  }

  @todo_list [
    ["prepare", "2268"],
    ["land", "2268"]
  ]
end
