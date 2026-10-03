# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1121-layers-from-geometry-and-the-missing-categories.exs
defmodule Rfd1121 do
  use Taskweft.DSL

  @name "rfd_1121"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1121": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1121": 0}}
  }

  @todo_list [
    ["prepare", "1121"],
    ["land", "1121"]
  ]
end
