# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1037-composite-models-as-taskweft-domains.exs
defmodule Rfd1037 do
  use Taskweft.DSL

  @name "rfd_1037"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1037": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1037": 0}}
  }

  @todo_list [
    ["prepare", "1037"],
    ["land", "1037"]
  ]
end
