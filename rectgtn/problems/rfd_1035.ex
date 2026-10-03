# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1035-legacy-model-identifiers.exs
defmodule Rfd1035 do
  use Taskweft.DSL

  @name "rfd_1035"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1035": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1035": 0}}
  }

  @todo_list [
    ["prepare", "1035"],
    ["land", "1035"]
  ]
end
