# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1133-models-excluded-from-conversion.exs
defmodule Rfd1133 do
  use Taskweft.DSL

  @name "rfd_1133"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1133": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1133": 0}}
  }

  @todo_list [
    ["prepare", "1133"],
    ["land", "1133"]
  ]
end
