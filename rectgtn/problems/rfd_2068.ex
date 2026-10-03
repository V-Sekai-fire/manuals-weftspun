# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2068-sccache-github-actions-cache-for-godot-builds.exs
defmodule Rfd2068 do
  use Taskweft.DSL

  @name "rfd_2068"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2068": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2068": 0}}
  }

  @todo_list [
    ["prepare", "2068"],
    ["land", "2068"]
  ]
end
