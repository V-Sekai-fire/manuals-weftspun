# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2389-the-sandbox-addon-is-built-at-double.exs
defmodule Rfd2389 do
  use Taskweft.DSL

  @name "rfd_2389"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2389": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2389": 1}}
  }

  @todo_list [
    ["prepare", "2389"],
    ["land", "2389"]
  ]
end
