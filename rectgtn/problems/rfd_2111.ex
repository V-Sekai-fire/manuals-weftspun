# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2111-convert-the-deployment-words.exs
defmodule Rfd2111 do
  use Taskweft.DSL

  @name "rfd_2111"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2111": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2111": 0}}
  }

  @todo_list [
    ["prepare", "2111"],
    ["land", "2111"]
  ]
end
