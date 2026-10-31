# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2359-the-shopkeeper-keeps-the-books-for-each-conversation.exs
defmodule Rfd2359 do
  use Taskweft.DSL

  @name "rfd_2359"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2359": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2359": 1}}
  }

  @todo_list [
    ["prepare", "2359"],
    ["land", "2359"]
  ]
end
