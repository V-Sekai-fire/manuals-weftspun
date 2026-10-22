# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2323-frontier-learning-picks-the-stores-adversarial-runs.exs
defmodule Rfd2323 do
  use Taskweft.DSL

  @name "rfd_2323"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2323": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2323": 0}}
  }

  @todo_list [
    ["prepare", "2323"],
    ["land", "2323"]
  ]
end
