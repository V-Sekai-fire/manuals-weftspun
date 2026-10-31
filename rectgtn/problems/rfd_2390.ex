# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2390-every-elf-guest-ships-with-its-native-translation.exs
defmodule Rfd2390 do
  use Taskweft.DSL

  @name "rfd_2390"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2390": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2390": 1}}
  }

  @todo_list [
    ["prepare", "2390"],
    ["land", "2390"]
  ]
end
