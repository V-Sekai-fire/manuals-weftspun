# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2178-qaft-4bit-across-the-stack.exs
defmodule Rfd2178 do
  use Taskweft.DSL

  @name "rfd_2178"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2178": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2178": 0}}
  }

  @todo_list [
    ["prepare", "2178"],
    ["land", "2178"]
  ]
end
