# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2036-forward-renderer-baked-light.exs
defmodule Rfd2036 do
  use Taskweft.DSL

  @name "rfd_2036"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2036": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2036": 0}}
  }

  @todo_list [
    ["prepare", "2036"],
    ["land", "2036"]
  ]
end
