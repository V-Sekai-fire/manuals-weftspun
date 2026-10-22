# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1064-character-concept-generator.exs
defmodule Rfd1064 do
  use Taskweft.DSL

  @name "rfd_1064"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1064": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1064": 0}}
  }

  @todo_list [
    ["prepare", "1064"],
    ["land", "1064"]
  ]
end
