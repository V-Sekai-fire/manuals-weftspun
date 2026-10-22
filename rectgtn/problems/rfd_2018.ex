# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2018-feature-classification-poc-baseline-stretch.exs
defmodule Rfd2018 do
  use Taskweft.DSL

  @name "rfd_2018"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2018": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2018": 0}}
  }

  @todo_list [
    ["prepare", "2018"],
    ["land", "2018"]
  ]
end
