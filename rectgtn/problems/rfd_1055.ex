# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1055-beam-workers-local-first.exs
defmodule Rfd1055 do
  use Taskweft.DSL

  @name "rfd_1055"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1055": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1055": 0}}
  }

  @todo_list [
    ["prepare", "1055"],
    ["land", "1055"]
  ]
end
